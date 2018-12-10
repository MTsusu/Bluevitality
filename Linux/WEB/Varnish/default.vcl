/*
	vcl_recv：				用于接收/处理请求；当请求到达并成功接收后被调用，通过判断请求的数据来决定如何处理请求
	vcl_pipe：				此函数在进入pipe模式时被调用，用于将请求直接传递至后端主机，并将后端响应原样返回客户端
	vcl_pass：				此函数在进入pass模式时被调用，用于将请求直接传递至后端主机，但后端主机的响应并不缓存而是直接返回客户端
	vcl_hit：				在执行 lookup 指令后，在缓存中找到请求的内容后将自动调用该函数
	vcl_miss：				在执行 lookup 指令后，在缓存中没有找到请求的内容时自动调用该方法，此函数可用于判断是否需要从后端服务器获取内容
	vcl_hash：				在vcl_recv调用后为请求创建一个hash值时，调用此函数；此hash值将作为varnish中搜索缓存对象的key
	vcl_purge：				pruge操作执行后调用此函数，可用于构建一个响应
	vcl_deliver：				将在缓存中找到请求的内容发送给客户端前调用此方法
	vcl_backend_fetch：			向后端主机发送请求前，调用此函数，可修改发往后端的请求
	vcl_backend_response：			获得后端主机的响应后，可调用此函数
	vcl_backend_error：			当从后端主机获取源文件失败时调用此函数
	vcl_init：				VCL加载时调用此函数，经常用于初始化varnish模块(VMODs)
	vcl_fini：				当所有请求都离开当前VCL，且当前VCL被弃用时调用此函数，经常用于清理varnish模块
*/

vcl 4.0;                                     #指明版本兼容性，提供向后兼容

import directors;                            #导入后端服务器模块

probe web_check {                            #定义健康状态检测
    .url = "/";                              #检查的URL路径
    .expected_response = 200;                #期望的响应状态码（默认200）
    .window = 8;                             #检查次数
    .threshold = 4;                          #最小健康次数
    .interval = 2s;                          #检查频率2s/次
    .timeout = 1s;                           #超时
}

backend default {                            #定义后端主机
    .host = "172.16.252.205";                #Host:port
    .port = "80";
    .host_header = "nginx12.1"               #定义主机专有的首部
    .connect_timeout = 0.5s;
    .first_byte_timeout = 20s;
    .between_bytes_timeout = 5s;
    .max_connections = 8000;                 #最大并发数量
    .probe = web_check;                      #健康状态检测
}

backend imageserver {                        #backend服务器若未被调用则不能事先定义...
    .host = "172.16.253.145";
    .port = "80";
    .connect_timeout = 0.5s;
    .first_byte_timeout = 20s;
    .between_bytes_timeout = 5s;
    .probe = {
        .url = "/test.jpg";
        .timeout = 0.3 s; 
        .window = 8;
        .threshold = 3;
        .initial = 3;
    }
}

backend php_server1 {
    .host = "172.16.253.140";
    .port = "80";
}

backend php_server2 {
    .host = "172.16.253.140";
    .port = "80";
}

/* VCL 的初始化引擎 */
sub vcl_init {
    new cluster1 = directors.round_robin();             	#创建后端集群，基于round_robin策略进行调度
    cluster1.add_backend(default,2);                    	#add_backend(<Host_token>,[weight]);  
    cluster1.add_backend(imageserver,1);                	#
        	
    new php_cluster = directors.hash();                 	#创建后端集群，基于hash策略进行调度
    php_cluster.add_backend(php_server1);               	#
    php_cluster.add_backend(php_server2);               	#
}

acl allow_purge_cache_address {
    "127.0.0.1";
    "192.168.0.0/16"
    "172.0.0.0"/8;
    "10.0.0.0"/8;
}

sub vcl_recv {
    if (! req.backend.healthy) {
        set req.grace = 5m;
    } else {
        set req.grace = 15s;
    }
    if (req.url ~ "(?i).*php$") {                           	#跟据动静分离的原则使用不同的backend集群（在vcl_init中定义）
        set req.backend_hint = php_cluster.backend();
    } else {
        set req.backend_hint = cluster1.backend();
    }
    /*
    if (req.http.host ~ "(?i)^(www.)?lnmmp.com$") {         	#根据不同的访问域名的原则分发至不同的的backend集群
        set req.http.host = "www.lnmmp.com";
        set req.backend_hint = web_cluster.backend();
    } elsif (req.http.host ~ "(?i)^images.lnmmp.com$") {
        set req.backend_hint = img_cluster.backend();
    }
    */
    if (req.url ~ "^/login" || req.url ~ "^/admin") {       	#测试或管理页面不进行缓存处理（不区分大小写："(?i)^/login"）
        return(pass);                                       	#不进行缓存查找，（直接通过backend_fetch来请求后端）
    }	
    if (req.method == "PRI"){					#varnish do not support SPDY or HTTP/2.0
        return (synth(405));					#未识别的新方法交由synth处理
    }
    if (req.restarts == 0) {                                 	#为第1次请求本主机的C端在向后端主机请求时添加"X-Forward-For"首部（排除rewrite）
        if (req.http.X-Forward-For) {                      
	        set req.http.X-Forward-For = req.http.X-Forward-For + "," +client.ip;
        } else {
	        set req.http.X-Forward-For = client.ip;
        }
    }
    if (req.request != "GET" &&                             	#将不理解的HTTP方法直接交给后端服务器处理
        req.request != "HEAD" &&  
        req.request != "PUT" &&  
        req.request != "POST" &&  
        req.request != "TRACE" &&  
        req.request != "OPTIONS" &&  
        req.request != "DELETE") {  
            return (pipe);  
    }  
    if (req.request != "GET" && req.request != "HEAD" ){
        return (pipe);
    }
    if (req.method == "PURGE"){
        if (client.ip !~ allow_purge_cache_address) {
            return (synth(444,"Not enough authority to " + client.ip));
        }
        return(purge);
    }
    if (req.http.Authorization || req.http.Cookie) {        	#不进行缓存
        return (pass);
    }
    /*  
    if (req.http.User-Agent ~ "(?i)curl") {
        return (synth(405,"No good"));
    }
    */
    return(hash);                                           	#将剩余对象交给vcl_hash处理
}

/* 对hash的键进行定义和缓存 */
sub vcl_hash {
    hash_data(req.url); 					#对请求报文的URL进行哈希
    if (req.http.host) {  
        hash_data(req.http.host);  				#若存在host首部则对其哈希，否则对服务器地址进行哈希
    } else {  
        hash_data(server.ip);  
    }  
    if(req.http.Accept-Encoding){                           	#持压缩的要增加，防止发送给不支持压缩的浏览器压缩的内容  
         hash_data(req.http.Accept-Encoding);  
    }
    /* 进行缓存 */
    return (hash); 						#如上3步将哈希的键构建为：URL + Server host + Accept-Encoding
}

sub vcl_backend_fetch {						#从后台服务器取回数据后,视情况是否进行缓存  
    if (req.url ~ "^(.*)\.(aspx|asmx|ashx)($|.*)") {		#如果请求的是动态页面直接发转发，动态请求回来的一定要放在前面处理  
        set beresp.http.Cache-Control="no-cache, no-store";  
        unset beresp.http.Expires;  
        return (deliver);  
    }  
    if (beresp.ttl > 0s) {			#仅当该请求可缓存时才设置beresp.grace，若该请求不能被缓存则不设置beresp.grace  
        set beresp.grace = 1m;  
    }    
    if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {  
            # Mark as "Hit-For-Pass" for the next 2 minutes
            set beresp.ttl = 120 s;
            return (hit_for_pass);  				#下次请求时不进行lookup,直接pass 
    } 
    if (beresp.http.Pragma ~"no-cache" || beresp.http.Cache-Control ~"no-cache" || beresp.http.Cache-Control ~"private") {  
            return (deliver);					#从后台服务器返回的response信息中,没有缓存的不缓存  
    }  
    set beresp.grace = 30m;
    return (deliver);  
}  

sub vcl_backend_response {
    /* 对特定类型的资源取消其私有的cookie标识 */
    if (beresp.http.cache-control !~ "s-maxage" ) {         	#s-maxage一般用在cache服务器上(如CDN)并只对public缓存有效
        if (bereq.url ~ "^(.*)\.(pdf|xls|ppt|doc|docx|xlsx|pptx|chm|rar|zip)($|\?)") {  
            unset beresp.http.Set-Cookie;  
            set beresp.ttl = 30d;  				#设置从后后端获得的特定格式文件的缓存TTL  
            return (deliver);  
        } else if (bereq.url ~ "^(.*)\.(bmp|jpeg|jpg|png|gif|svg|png|ico|txt|css|js|html|htm)($|\?)") {   
            unset beresp.http.Set-Cookie;  
            set beresp.ttl = 15d;   
            return (deliver);  
        } else if (bereq.url ~ "^(.*)\.(mp3|wma|mp4|rmvb|ogg|mov|avi|wmv|mpeg|mpg|dat|3pg|swf|flv|asf)($|\?)") {  
            unset beresp.http.Set-Cookie;                   	#对媒体资源取消其私有cookie设置功能
            set beresp.ttl = 30d;  
            return (deliver);   
        }
    }
    return (deliver); 
}

sub vcl_deliver {
    if (obj.hits>0) {                                       	#缓存命中次数
        set resp.http.X-Cache = "HIT from "  + server.ip;
    } else {
        set resp.http.X-Cache = "MISS from " + server.ip;
    } 
    unset resp.http.Vary;
    unset resp.http.X-Powered-By;
    unset resp.http.X-AspNet-Version;
}

sub vcl_error {  
	set obj.http.Content-Type = "text/html; charset=utf-8";  
	set obj.http.Retry-After = "5";  
	synthetic {"  
	<?xml version="1.0" encoding="utf-8"?>  
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">  
	<html>  
		<head>  
			<title>"} + obj.status + " " + obj.response + {"</title>  
		</head>  
		<body>  
			<h1>Error "} + obj.status + " " + obj.response + {"</h1>  
			<p>"} + obj.response + {"</p>  
			<h3>Guru Meditation:</h3>  
			<p>XID: "} + req.xid + {"</p>  
			<hr>  
			<p>Varnish cache server</p>  
		</body>  
	</html>  
	"};  
	return (deliver);  
}
sub vcl_pass { 
    /* 不进行缓存查找 */
    if (req.request == "PURGE") {
        return(synth(502,"PURGE on a passed object"));
    }
    return (pass);  
}

sub vcl_hit {                                              	#命中（动作：deliver/pass）
    if (req.request == "PURGE") {                           	#PURGE请求的处理
        purge;
        return(synth(200,"Purged"));
    }
	return (deliver);  
}  

sub vcl_miss {							#未命中（动作：fetch/pass）
    if (req.request == "PURGE") {
        purge;                                              	#PURGE请求的处理
        return(synth(404,"Not in cache"));
    }
    return (fetch);  
}

sub vcl_fini {  
    return (ok);  
}


