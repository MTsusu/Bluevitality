cat > XXX-upstream.conf <<'eof'
upstream fupin {
	check interval=3000 rise=2 fall=5 timeout=1000 type=tcp;
	server 192.168.1.1:1011;
	server 192.168.1.2:1011;
	server 192.168.1.3:1011;
}
eof

#日志按天生成时的日志文件名中年月日变量部分从变量"time_iso8601"获取，禁用不安全的方法
cat > ~/nginx/conf/server_general.conf <<'eof'
if ($request_method !~ ^(GET|POST|HEAD|PUT|DELETE)) {
        return 444;
        }
if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
}
location ~ /nginx_status {
        access_log off;
        allow 192.168.0.0/16;
        deny all;
}
eof

ADDRESS=`hostname -i`
cat > 工程名.conf <<'eof'
server {
    listen 80;
    server_name ${ADDRESS};
    include server_general.conf;
    location / {
        include proxy_header.conf;
        proxy_pass http://工程名;
        access_log logs/工程名-access-$year-$month-$day.log main;
    }
}
eof

#反向代理相关设置
cat > ~/nginx/conf/proxy_header.conf <<'eof'
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $remote_addr;
  proxy_set_header REMOTE_ADD $remote_addr;
  proxy_redirect http:// $scheme://;
eof

# ----------------------------------------------------------------------------------------------- nginx.conf

cat > ~/nginx/conf/nginx.conf <<'eof'
worker_processes  32;
pid  logs/nginx.pid;
events {
    worker_connections  1024000;
    use epoll;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    set_real_ip_from 192.168.0.0/16;
    real_ip_header X-Forwarded-For;

    log_format main  '$time_local || $remote_addr || $upstream_addr ||  $status || $request_time || $upstream_status'
                     ' || $upstream_response_time || $upstream_cache_status || $body_bytes_sent || $http_referer'
                     ' || $remote_user || $http_user_agent || $http_x_forwarded_for || $request';

    sendfile        on;
    keepalive_timeout  15;
    server_names_hash_bucket_size 128;
    tcp_nopush on;   
    tcp_nodelay on; 
    server_tokens off;
    charset utf8;

    proxy_cache cache_one;
    proxy_cache_path tmp/proxy_cache levels=1:2 keys_zone=cache_one:100m inactive=2d max_size=1g;
    proxy_next_upstream off;
    proxy_read_timeout 300;
    proxy_send_timeout 300;
    proxy_buffer_size 16k;
    proxy_buffers 4 16k;
    proxy_busy_buffers_size 32k;
    proxy_temp_file_write_size 32k;
    proxy_temp_path tmp/proxy_temp;
    proxy_ignore_client_abort on;

    client_header_buffer_size   2k;
    large_client_header_buffers 4 16k;
    client_max_body_size 100m;
    
    gzip on;
    gzip_min_length     2k;
    gzip_buffers        4       16k;
    gzip_comp_level     2;
    gzip_types       text/js image/jpeg image/png text/plain text/css text/javascript application/json application/javascript;
    gzip_vary on;
    gzip_proxied  expired no-cache no-store private auth;

    include conf.d/tcp/*-tcp.conf;
    include conf.d/vhost/app/*.conf;
    include conf.d/upstream/app/*-upstream.conf;

   #stream {
     #upstream proxy_guizhou {
        #server XX.XX.XX.XX:XXX;
        #check interval=3000 rise=2 fall=5 timeout=1000;
        #check_http_send "GET /HTTP/1.0\r\n\r\n";
        #check_http_expect_alive http_2xx http_3xx;
    #}
    
   #server {
        #listen 10000;
        #proxy_pass proxy_guizhou;
   #}
}
eof

cd ~/nginx
mkdir -p tmp/proxy_cache
mkdir -p tmp/proxy_temp
mkdir -p conf/conf.d/tcp
mkdir -p conf/vhost/app
mkdir -p conf/upstream/app

