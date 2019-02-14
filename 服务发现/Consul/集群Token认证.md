```bash
#Consul服务端
[root@node1 ~]# echo  "{\"encrypt\":\"$(consul keygen)\"}" > encrypt.json   #生成Token到Json格式的配置文件
[root@node1 ~]# cat encrypt.json 
{"encrypt":"A91/lwA3pN6mjfHIZ2kglg=="}
[root@node1 ~]# consul agent -server -rejoin -bootstrap -data-dir /var/consul -node=node1 \
-config-dir=/etc/consul.d/ -bind=192.168.0.5  -client 0.0.0.0 \
-config-file encrypt.json                                                   #载入Token配置

#Consul客户端
[root@node2 ~]# echo '{"encrypt":"A91/lwA3pN6mjfHIZ2kglg=="}' > encrypt.json    #使用Consul服务端生成的Token
[root@node2 ~]# consul agent -ui -data-dir /var/consul -node=node2 -bind=192.168.0.6 \
-datacenter=dc1 -config-dir=/etc/consul.d/ -join 192.168.0.5 -config-file encrypt.json


#验证...
[root@node1 ~]# consul members    
Node   Address           Status  Type    Build  Protocol  DC
node1  192.168.0.5:8301  alive   server  0.8.1  2         dc1
node2  192.168.0.6:8301  alive   client  0.8.1  2         dc1
```
