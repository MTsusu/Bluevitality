#### 构建集群的前提条件
1. 所有的集群成员都需要 NTP 的时间同步
2. 修改各集群成员主机名  
 `~]# vim /etc/sysconfig/network`  
 `~]# vim /etc/hosts`  
 `~]# hostnamectl set-hostname <HOST_NAME>`
3. 修改各集群成员间的 /etc/hosts 将成员的主机名与地址做映射  
 `~]# uname -n`
4. 必要时进行集群间 SSH 的互信...

#### HA Cluster 组件说明
```txt
HA 术语：
    CRM 集群资源管理器 Cluster Resource Manager，一系列的集群事物由其完成管理
    LRM 本地资源管理器，Pacemaker即是CRM又是LRM
    CIB 集群信息基库，其使用XML格式的配置文件，工作时常驻在内存中并且需要通知给除DC外的其它节点
    DC  集群中的一个节点会被选为指定的集群协调器，这意味着它具有主CIB
    RA  资源代理层（Resource Agents），RA是有类别的（查看RA类别：crm ra classes）
    PE  策略引擎（Policy Engine），来定义资源转移的一整套转移方式，其仅做策略而不执行资源转移的过程
    TE  即（Transition Engine），它就是来执行PE做出的策略的并且只有DC上才运行PE和TE!...
    
高可用集群大致可分为三个层次结构（不同的实现略有差异）由下而上大致可分为：

    1. Messaging 与 Membership 层：
        位于最底层的即信息和成员关系层 （简单来说本层主要负责传递心跳信息和集群事物信息）
        Messaging主要用于节点之间传递心跳信息，也称为心跳层。节点间传递心跳可通过广播，组播，单播等方式进行
        成员关系层"Membership"主要作用是主节点（DC）通过 Cluster Consensus Menbership Service（CCM或CCS）
        这种服务由"Messaging"层提供的信息通过计算来产生一个完整的成员关系。其主要实现承上启下的作用：
            承上，将下层产生的信息生产成员关系图传递给上层以通知各个节点的工作状态
            启下，将上层对于隔离某一设备予以具体实施
            
    2. Cluster Resource Manager（CRM）层：
        在该层中每个节点都运行一个集群资源管理器：CRM，它为HA提供核心组件，如资源定义及属性等
        在每个节点上CRM都维护一个称为CIB的集群信息库的XML文档和LRM（本地资源管理器）组件
        对于CIB来说，只有工作在DC（主节点）上的CIB文档是可以被修改的（由DC负责维护并同步给其他节点）
        CRM（集群资源管理器/层）是真正实现集群服务的层，其生成CIB使集群中所有成员都能了解整个集群所有配置状态等...
        DC负责维护主CIB文档，所有对CIB的修改都要由DC来实现，而后由DC同步给其他的节点，非DC的节点不进行CIB的同步

        
    3. Local Resource Manager（LRM）与 Resource Agent（RA）层：
        本地资源管理器：LRM，是执行CRM传递过来的在本地执行某个资源的执行/停止的一个具体的执行者
        当某个集群节点发生故障时由DC通过 PE（策略引擎）和 TE（实施引擎）来决定是否抢夺资源...
        资源代理层：RA（即Resource Agents），能够管理本节点上属于集群资源的某一资源的启动/停止/状态信息的脚本)
        
        资源代理分为：
            1.LSB (/etc/init.d/*)
            2.OCF (比LSB更专业，更加通用)
            3.Legacy (heartbeat v1版的资源管理)
    
ref：
    http://www.linuxidc.com/Linux/2013-08/88522.htm
    http://blog.csdn.net/leshami/article/details/49636955
```
![LB](https://assets.digitalocean.com/articles/high_availability/ha-diagram-animated.gif)
