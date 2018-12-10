#### Elasticsearch、Logstash、Kibana 介绍
```txt
完整的集中式日志系统离不开以下几个主要特点：
    1.收集 ---> 能采集多种来源的日志数据
    2.传输 ---> 能稳定的把日志数据传输到中央系统
    3.存储 ---> 如何存储日志数据
    4.分析 ---> 可以支持 UI 分析
    5.告警 ---> 能提供错误报告，监控机制

ELK不是软件，而是一整套解决方案! 它是三个软件产品的首字母缩写：Elasticsearch，Logstash，Kibana
这三款软件都是开源软件，通常是配合使用，它们又先后归于 Elastic.co 公司名下，故被简称为 ELK 协议栈...

---------------------------------------------------------------------------------------------------------------

[Elasticsearch]
    是开源的实时分布式搜索引擎，提供全文搜索，结构化搜索及分析，是建立在全文搜索引擎 Apache Lucene 基础上的，由Java编写
    支持丰富的插件来扩展其功能
    主要特点：
        实时分析
        分布式，零配置的实时文件存储，其将每个字段都编入索引
        文档导向：所有的对象全部是文档
        高可用性：易扩展，支持集群（Cluster）、索引自动分片和索引副本机制（Shards 和 Replicas）
        接口友好：支持 JSON（restful风格接口）
        多数据源，自动搜索负载等...

[Logstash]
    是具有实时渠道能力的数据收集引擎。使用 JRuby 编写（需要JVM）。其作者是世界著名的运维工程师乔丹西塞 JordanSissel
    是实现对产生日志的服务器部署agent并对其产生的日志收集后通过统一的管道来集中存储在Elasticsearch上的组件...
    是server/agent的结构，agent将产生的日志信息收集后发送给logstash-server并默认以时间序列为基准合并为1和序列后发送...
    为了防止Agent发送大量数据压垮server端，通常在a/s之间创建一个消息队列，通常是是redis（使用其发布订阅，列表的功能）
    Logstash也能实现索引的构建，但现在仅使用其执行日志的收集而已...其严重依赖插件，使用插件完成数据的输入，过滤，输出...
    Logstash最重要的input插件是file，其可利用Linux内核的Filewatch机制监听文件变化以实现实时的读取尾部信息并记录位置...
    主要特点：
        几乎可访问任何数据，支持多种数据获取机制，如：TCP/UDP，syslog，windows，Eventlog，STDIN....
        对日志进行收集、过滤、修改等操作并将其存储供以后使用
        可以和多种外部应用结合
        支持弹性扩展......

    它由三个主要部分组成：
        Shipper：    在Agent端，负责收集和发送日志数据
        Broker：     收集数据，缺省内置 Redis
        Indexer：    在server端，可按固定的格式条件清洗数据并将其发送至Elasticsearch Cluster
        
    Plugins：   （使用域类型定义DSL的方式配置）
        INPUT   实现输入，即从哪里取得Agent端收集的数据（redis）
        CODEC   实现编码（非必须）
        FILTER  实现过滤，如过滤特定字段，如web日志中的IP，若不需要额外处理则此插件可省略...
        OUTPUT  实现输出，发送至Elasticsearch Cluster 或其他...

[Kibana]
    是基于Apache开源协议，使用 JavaScript (nodjs) 编写，为Elasticsearch提供分析和可视化的Web平台
    它可以在Elasticsearch的索引中查找，交互数据，并生成各种维度的表图进行展示...
    Kibana可以为Logstash和ElasticSearch提供日志分析友好的Web界面，可帮助用户汇总、分析和搜索重要数据日志及趋势展示...
    ES本身就是一个独立且完整的搜索引擎，而Kibana是为其构建的直观易用的接口，而Logstash只是数据收集器中的一种...
    由于Logstash基于Jruby语言，因此其性能较慢（重量级），高度插件化...
    因此很多时候二次开发程序替代Logstash：自建Agent程序并发至消息队列（如Kafka），再由特定程序从MQ中取出存至Elastic!
    注：Kafka是一种分布式消息队列，其性能非常强大...

---------------------------------------------------------------------------------------------------------------

完整的ELK协议栈体系结构的基本流程：
    1.由Shipper负责从各类数据源采集数据然后发送到Broker
    2.然后由Indexer将存放在Broker中的数据再写入Elasticsearch
    3.Elasticsearch对这些数据创建索引
    4.然后由Kibana对其进行各种分析并以图表的形式展示...

E,L,K 三款软件之间互相配合使用，完美衔接，高效的满足了很多场合的应用...
```
#### Elasticsearch
```txt
Elastic的底层是开源库Lucene（全文搜索引擎）。但是用户无法直接使用Lucene，因为用户必须自己写代码去调用它的接口。
Elastic是Lucene的封装，提供了REST API 的操作接口，并且开箱即用!...
Elastic是接近实时的搜索平台。这意味着从索引一个文档直到这个文档能够被搜索到仅有一个轻微的延迟（通常是1s）
Elastic天生就是分布式的，并且在设计时屏蔽了分布式的复杂性!（ES尽可能地屏蔽了分布式系统的复杂性）...
    服务默认端口：      9300 
    Web管理平台端口：   9200

这里列举了一些Elasticsearch在后台自动执行的操作：
    分配文档到不同的容器或分片中，文档可储存在一或多个节点内
    按集群节点来均衡分配这些分片，从而对索引和搜索的过程实现负载均衡
    复制每个分片以支持数据冗余，从而防止硬件故障导致的数据丢失
    自动的将集群中任一节点的请求路由到真正存有相关数据的节点
    在集群扩容时无缝整合新节点，重新分配分片以便从离群节点恢复
    
---------------------------------------------------------------------------------------------------------------

基本概念：
    Node 与 Cluster：
        Elastic本质上是一个分布式数据库，允许多台服务器协同工作，每台服务器可运行多个Elastic实例
        单个 Elastic 实例称为一个节点（node）。若干的节点构成一个集群（cluster）
        各个 Elastic 节点共同持有你整个的数据，并一起提供索引和搜索功能
        集群由唯一的名字标识，默认是"elasticsearch"，节点只能通过指定某个集群的名字，来加入这个集群
        
    Index：
        索引是一种数据结构，它允许对存储在其中的单词进行快速且随机的访问...
        当需要从大量文本中快速检索文本目标时必须首先将文本内容转换成能够进行快速搜索的格式以建立针对文本的索引数据结构
        Elastic默认会索引所有字段，经处理后写入一个反向索引（Inverted Index）。并且再查找数据的时直接查找该索引
        Elastic数据管理的顶层单位就叫做Index（索引）。它是单个数据库的同义词。每个Index（即数据库）的名字必须小写
        
        查看当前节点的所有Index：curl -X GET 'http://localhost:9200/_cat/indices?v'
    
    Document：
        文档是一个可被索引的基础信息单元。比如你可以拥有某个客户的文档，某个产品的文档，当然也可以拥有某订单的文档
        文档以JSON格式表示，而JSON是到处存在的互联网数据交互格式...
        在一个index/type里面，只要你想，你可以存储任意多的文档。
        注意，尽管一个文档物理上存在于一个索引中，文档必须被索引/赋予一个索引的type...
        Index里面单条的记录称为Document（文档）。许多条 Document 构成了一个Index!...
        同一个Index里的Document，不要求有相同的结构（scheme）但是最好保持相同，这样有利于提高搜索效率...
        Document使用JSON表示的例子：
            {
                "user": "张三",
                "title": "工程师",
                "desc": "数据库管理"
            }
        
    Type：
        Document又可以分组，比如weather这个Index里面，可按城市分组（北京和上海），也可按气候分组（晴天和雨天）
        这种分组就叫做 Type，它是虚拟的逻辑分组，用来对Document进行过滤！...
        不同的Type应该有相似的结构（schema），举例来说，id字段不能在这个组是字符串，在另一组是数值。
        列出每个Index所包含的Type：curl 'localhost:9200/_mapping?pretty=true'
        根据规划，Elastic 6.x 版只允许每个 Index 包含一个 Type，7.x 版将会彻底移除 Type。
        
---------------------------------------------------------------------------------------------------------------

新建和删除Index：
    新建Index时可直接向Elastic服务器发出PUT请求。下面例子是新建一个名叫weather的Index：
        $ curl -X PUT 'localhost:9200/weather'
        
        服务器将返回一个JSON，里面的acknowledged字段表示操作成功：
            {
                "acknowledged": true,
                "shards_acknowledged": true
            }
            
        也可以发出DELETE请求来删除这个Index：
            $ curl -X DELETE 'localhost:9200/weather'

Elastic集群内节点的状态：
    green：
        所有的主分片和副本分片都已分配。当前集群 100% 可用
        
    yellow
        所有的主分片已经分片了，但至少还有一个副本是缺失的。虽然不会有数据丢失并且搜索结果依然是完整的。
        不过高可用性在某种程度上被弱化。若有更多的分片消失，你就会丢数据了
        
    red：
        至少一个主分片（以及它的全部副本）都在缺失中。这意味着你在缺少数据!
        搜索只能返回部分数据，而分配到这个分片上的写入请求会返回一个异常...

---------------------------------------------------------------------------------------------------------------

分片和复制（shards & replicas）：
    
    索引可存储超出单个结点硬件限制的数据!
    比如有10亿文档的索引占据1TB空间，而任一节点都没这样的空间，或单节点处理搜索请求时响应太慢
    为了解决这个问题，Elastic提供了将索引划成多份的能力，这些份就叫做分片!
    当创建索引时你可以指定想要的分片的数量。每个分片本身也是一个功能完善且独立的“索引”，它可被放置到集群任何节点
    至于一个分片怎样分布，它的文档怎样聚合回搜索请求，是完全由Elasticsearch管理的，对于用户来说这些都是透明的
    
    分片之所以重要，主要有两方面的原因：
        - 允许你水平分割/扩展内容容量
        - 允许你在分片（潜在地，位于多个节点上）之上进行分布式、并行的操作，进而提高性能/吞吐量...
    

    在一个网络/云的环境里，失败随时都可能发生，在某个分片/节点不知怎么的就处于离线状态，或者由于任何原因消失了
    此时故障转移机制是非常有用且强烈推荐的。为此目的Elastic允许创建分片的一或多份拷贝，它们叫做复制分片或干脆叫复制
    总之每个索引可以被分成多个片。一个索引也可被复制0次（意思是没有复制）或多次。
    一旦复制了，每个索引就有了主分片（作为复制源的原来的分片）和复制分片（主分片的拷贝）之别。    
    分片和复制的数量可在索引创建时指定。在索引创建后也可在任何时候动态地改变复制的数量，但事后不能改变分片数量！
    默认情况下Elastic中的每个索引被分片5个主分片和1个复制
    这意味着若集群至少有两个节点，则索引将会有5个主分片和另外5个复制分片（完全拷贝），这样每个索引总共就有10个分片
    
    复制之所以重要，有两个主要原因：
        - 在分片/节点失败时提供HA。因此注意到复制分片不与原/主要（original/primary）分片置于同一节点上非常重要的
        - 扩展你的搜索量/吞吐量，因为搜索可以在所有的复制上并行运行

Elastic的主要文件：
[root@node2 ~]# rpm -ql elasticsearch | grep -e bin -e etc -e 'usr/share/elasticsearch/plugins'
/etc/elasticsearch
/etc/elasticsearch/elasticsearch.yml                #主配置文件
/etc/elasticsearch/logging.yml
/etc/elasticsearch/scripts
/etc/init.d/elasticsearch                           #启动脚本
/etc/sysconfig/elasticsearch
/usr/share/elasticsearch/bin
/usr/share/elasticsearch/bin/elasticsearch
/usr/share/elasticsearch/bin/elasticsearch-systemd-pre-exec
/usr/share/elasticsearch/bin/elasticsearch.in.sh
/usr/share/elasticsearch/bin/plugin                 #插件安装程序
/usr/share/elasticsearch/plugins                    #插件存放目录，可手动直接存放插件

#Plugin...
[root@node2 ~]# /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head     #从默认源安装插件
-> Installing mobz/elasticsearch-head...
Trying https://github.com/mobz/elasticsearch-head/archive/master.zip ...
Downloading .......(略)....................DONE
Verifying https://github.com/mobz/elasticsearch-head/archive/master.zip checksums if available ...
NOTE: Unable to verify checksum for downloaded plugin (unable to find .sha1 or .md5 file to verify)
Installed head into /usr/share/elasticsearch/plugins/head
[root@node2 ~]# /usr/share/elasticsearch/bin/plugin list                                #列出安装的插件
Installed plugins in /usr/share/elasticsearch/plugins:                                  #以下都是常用的...
    - head                                  #以下都是站点类型的插件，可通过 _site/<plugin_name> 的API方式访问
    - kopf                                  #ES的API方式的管理工具
    - bigdesk                               #ES集群的监控工具
    - marvel-agent                          #Marvel能够让你通过Kibana非常容易的监视ES

#站点类型的插件访问方式：【在浏览器中通过: http://address:9200/_plugin/<插件名>/ 的方式访问】
[root@node2 bigdesk]# curl http://192.168.0.6:9200/_site/marvel/?pretty
{
  "error" : {
    "root_cause" : [ {
      "type" : "illegal_argument_exception",
      "reason" : "No feature for name [marvel]"
    } ],
    "type" : "illegal_argument_exception",
    "reason" : "No feature for name [marvel]"
  },
  "status" : 400
}
```
