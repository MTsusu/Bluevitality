###### filebeat   -->   kafka   -->   logstash   -->   Elasticsearch   -->   Kibana
#### filebeat
```bash
filebeat:
  prospectors:
    - paths:
        - /home/wangyu/Test/access.log
      input_type: log
      document_type: oslog
      scan_frequency: 2s              #Every 2s scan ..
output.kafka: 
  enabled: true 
  hosts: ["10.0.0.3:9092"]
  topic: ES                           #MQ Topic
  partition.round_robin:
    required_acks: 1                  #Need kafka Ack
    max_message_bytes: 1000000
#output.console:
#    pretty: true
```
#### kafka
```bash
#在Kafka的Broker端创建"Logstash"消费的主题
kafka-topics.sh --create --zookeeper 10.0.0.3:21811 --replication-factor 1 --partitions 1 --topic ES
```
#### Logstash
```bash
input{
    kafka {
        bootstrap_servers => "10.0.0.3:9092"    #Kafka Address
        group_id => "logstash"                  #要启用消费组，同组的消费者间"竞争"消费相同主题的1个消息
        topics => "ES"                          #消费主题，生产环境中可使用列表类型来订阅多个主题
        consumer_threads => 2
        decorate_events => true                 #属性会将当前topic、offset、group、partition等信息也带到message中
        auto_commit_interval_ms => 1000         #消费间隔，毫秒
        auto_offset_reset => latest             #
        codec => "json"                         #将Filebeat传输的消息解析为JSON格式
    }
}

filter{
    grok {
        match => { 
            #Grok从message语义中按Patterns获取并分割成Key，其表达式很像C语言中的宏定义
            "message" => '%{IP:client} - - \[%{DATA:time}\] "%{DATA:verb} %{DATA:url_path} %{DATA:httpversion}" %{NUMBER:response} %{NUMBER:} "-" \"%{DATA:agent}\" "-" \"%{NUMBER:request_time}\" -' 
        }
    }
    mutate{ 
        remove_field => ["tags","topic","source","version","name"]  #删除Logstash中部分不需要的"语义"Key
        add_field => [ "log_ip", "10.0.0.3" ]                       #添加指定KEY
    }
}

output{
    if [type] == "log" {
        elasticsearch {
            hosts => ["10.0.0.3:9200"]          #ES根据请求体中提供的数据自动创建映射 (由Logstash自动创建的模板)
            index => "es"                       #索引名不要大写!
            timeout => 300
            flush_size：100                     #默认500，logstash攒够500条数据再一次性向es发送
            idle_flush_time：2                  #默认1s，如果1s内没攒够500条还是会一次性将攒的数据发出去给es
        }
    }
#    stdout {
#        codec => "rubydebug"
#    }
}
```
