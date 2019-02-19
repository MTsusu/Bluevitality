#### 在Manager节点为Node节点设置约束条件，此处设置的约束为lable
```bash
[root@node1 ~]# docker node update --label-add security=high node2  #在manager中为node2节点设置标签
[root@node1 ~]#  docker node inspect node2 | grep -A 2 "Labels"     #检查...
            "Labels": {
                "security": "high"
            },
[root@node1 ~]# docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
0w6j0cdz5scm36xrnq380ymek *  node1     Ready   Active        Leader
72lkynzdke93zbz9r6wobvh7z    node3     Ready   Active        
9tkkcbrwustuqvibm3v9j8qbn    node2     Ready   Active        
```
#### 使用约束表达式使nginx服务运行在特定Node上
```bash
[root@node1 ~]# docker service create --name nginx --publish 100:80 \
--constraint 'node.labels.security==high' docker.io/nginx

[root@node1 ~]# docker service ps nginx
ID                         NAME     IMAGE            NODE   DESIRED STATE  CURRENT STATE             ERROR
20x90h1c2s8pfvt25nqjop0vy  nginx.1  docker.io/nginx  node2  Running        Preparing 11 seconds ago  
[root@node1 ~]# docker node ps node2                                #查看Node2上是否存在nginx任务
ID                         NAME     IMAGE            NODE   DESIRED STATE  CURRENT STATE          ERROR
20x90h1c2s8pfvt25nqjop0vy  nginx.1  docker.io/nginx  node2  Running        Running 6 seconds ago 
```
#### Swarm的相关约束
```txt
节点属性        匹配	                        示例
node.id         节点 ID                       node.id == 2ivku8v2gvtg4
node.hostname   节点 hostname                 node.hostname != node02
node.role       节点 role: manager            node.role == manager
node.labels     用户自定义 node labels         node.labels.security == high
engine.labels   Docker Engine labels          engine.labels.operatingsystem == ubuntu 14.04
```


