#### HTTP 方式
```txt
# 反代模块：
#     主：proxy_module
#     子：proxy_module_http,proxy_module_ajp

<VirtuaHost *:80>
    Servername web1.test.com
    ProxyVia On
    ProxyRequests Off                                               #关闭正向代理
    ProxyPreserveHost On
    <Porxy>
        Require all granted
    </Proxy>
    ProxyPass /status !                                             #不使用反向代理
    ProxyPass / http://172.16.0.2:8080/                             #
    ProxyPassReverse / http://172.16.0.2:8080/
    <Location />
        Require all granted
    </Location>
```

#### AJP 方式
```txt
# 反代模块：
#     主：proxy_module
#     子：proxy_module_http,proxy_module_ajp

<VirtuaHost *:80>
    Servername web1.test.com
    ProxyVia On
    ProxyRequests Off                                               #关闭正向代理
    ProxyPreserveHost On
    <Porxy>
        Require all granted
    </Proxy>
    ProxyPass /status !                                             #不使用反向代理
    ProxyPass / ajp://172.16.0.2:8080/                              #
    ProxyPassReverse / ajp://172.16.0.2:8080/
    <Location />
        Require all granted
    </Location>
```
