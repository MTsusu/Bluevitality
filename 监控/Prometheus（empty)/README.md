##### https://prometheus.io/docs/introduction/overview/
```txt
Prometheus的基本原理是通过HTTP协议周期性抓取被监控组件的状态：
    支持通过配置文件、文本文件、Zookeeper、Consul、DNS SRV Lookup等方式指定抓取目标
    采用PULL的方式进行监控，即服务器可以直接通过目标PULL数据或者间接地通过中间网关来Push数据
    在本地存储抓取的所有数据，并通过一定规则进行清理和整理数据，并把得到的结果存储到新的时间序列中
    任意组件只要提供对应的HTTP接口就可以接入监控。
    通过PromQL和其他API可视化地展示收集的数据
    支持很多方式的图表可视化，例如Grafana、自带的Promdash以及自身提供的模版引擎等等
    还提供HTTP API的查询方式，自定义所需要的输出
    PushGateway支持Client主动推送metrics到PushGateway，而Prometheus只是定时去Gateway上抓取数据
    社区提供了大量的官方以及第三方Exporters，以满足Prometheus的采纳者快速实现对关键业务及基础设施的监控需求

输出被监控组件信息的HTTP接口被叫做exporter：
    目前互联网公司常用的组件大部分都有exporter可以直接使用
    比如Varnish、Haproxy、Nginx、MySQL、Linux系统信息 (包括磁盘、内存、CPU、网络等等)

Alertmanager:
    是独立于Prometheus的一个组件，可以支持Prometheus的查询语句，提供十分灵活的报警方式
```
![prometheus](https://prometheus.io/assets/architecture.png)
