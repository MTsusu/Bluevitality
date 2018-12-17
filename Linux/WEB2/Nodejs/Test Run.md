#### 创建nodejs项目并运行
```bash
[root@localhost /]# mkdir -p /usr/local/nodejs/
[root@localhost /]# mkdir -p /nodejs
[root@localhost /]# cd nodejs/
[root@localhost nodejs]# cat > nodejs_hello.js <<eof
> var http = require("http");
> http.createServer(function(request, response) {
> response.writeHead(200, {
> "Content-Type" : "text/plain" // 输出类型
> });
> response.write("Hello World");// 页面输出
> response.end();
> }).listen(8100); // 监听端口号
> console.log("nodejs start listen 8102 port!");
> eof
[root@localhost nodejs]# pm2 start nodejs_hello.js 
[PM2] Starting /nodejs/nodejs_hello.js in fork_mode (1 instance)
[PM2] Done.
┌──────────────┬────┬──────┬──────┬────────┬─────────┬────────┬─────┬──────────┬──────┬──────────┐
│ App name     │ id │ mode │ pid  │ status │ restart │ uptime │ cpu │ mem      │ user │ watching │
├──────────────┼────┼──────┼──────┼────────┼─────────┼────────┼─────┼──────────┼──────┼──────────┤
│ nodejs_hello │ 0  │ fork │ 2816 │ online │ 0       │ 0s     │ 1%  │ 7.2 MB   │ root │ disabled │
└──────────────┴────┴──────┴──────┴────────┴─────────┴────────┴─────┴──────────┴──────┴──────────┘
 Use `pm2 show <id|name>` to get more details about an app
```

#### 测试
```bash
[root@localhost nodejs]# netstat -atupnl | grep node
tcp6       0      0 :::8100                 :::*                    LISTEN      2816/node /nodejs/n 
[root@localhost nodejs]# curl localhost:8100
Hello World
