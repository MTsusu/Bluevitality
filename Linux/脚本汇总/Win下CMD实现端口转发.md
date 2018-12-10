##### 设置端口转发
```cmd
C:\Users\localhost >netsh interface portproxy add ?
add v4tov4     - 添加通过 IPv4 的 IPv4 和代理连接到的侦听项目。
add v4tov6     - 添加通过 IPv6 的 IPv4 和代理连接到的侦听项目。
add v6tov4     - 添加通过 IPv4 的 IPv6 和代理连接到的侦听项目。
add v6tov6     - 添加通过 IPv6 的 IPv6 和代理连接到的侦听项目。

netsh interface portproxy add v4tov4 listenaddress=<address> listenport=<port> connectaddress=<address> connectport=<port>
```
#### 取消端口转发
```cmd
netsh interface portproxy delete v4tov4 listenaddress=<address>  listenport=<port>
```
#### 查看端口转发配置信息
```cmd
netsh interface  portproxy show  v4tov4
```
