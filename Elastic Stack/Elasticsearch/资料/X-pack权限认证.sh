#权限控制
#修改kibana密码：修改之前需在kibana.yml中配置elasticsearch的用户名/密码后才能需改，否则报错。
xpack.security.enabled: true
elasticsearch.username: "elastic"
elasticsearch.password: "changeme"

#注意！同时需要在logstash中添加对ES的用户认证
#ES添加认证(默认：elastic:changeme)


#在Elasticsearch端添加新用户
curl -XPOST -u "elastic:changeme" '192.168.44.128:9200/_xpack/security/user/wangyu?pretty' -d'
{
  "password" : "123456",
  "roles" : [ "admin", "other_role1" ], #可以指定用户的role角色
  "full_name" : "Jack Nicholson",
  "email" : "wangyu@example.com",
  "metadata" : {
    "intelligence" : 7
  },
  "enabled": true
}'

#删除用户
curl -XDELETE '192.168.44.128:9200/_xpack/security/user/wangyu?pretty'
#修改密码
curl -XPUT '192.168.44.128:9200/_xpack/security/user/elastic/_password?pretty' -d' { "password": "elasticpassword" }'
curl -XPUT '192.168.44.128:9200/_xpack/security/user/kibana/_password?pretty' - d '{ "password": "kibanapassword"  }'
#查询所有Roles：
curl -XGET -u elastic '192.168.44.128:9200/_xpack/security/role'
#增加Roles：
curl -XPOST -u elastic '192.168.44.128:9200/_xpack/security/role/clicks_admin' -d '
{ "indices" : [ { "names" : [ "events*" ], "privileges": [ "all" ] },  { "names": [ ".kibana*" ], "privileges": [ "manage", "read", "index" ]} ]}'
#查询具体Roles：
curl -XGET -u elastic '192.168.44.128:9200/_xpack/security/role/clicks_admin'
#删除具体Roles：
curl -XDELETE -u elastic '192.168.44.128:9200/_xpack/security/role/clicks_admin'


#登录到Kibana会发现elastic是一个最高级别的user，拥有所有权限，其角色是superuser。
#当然在这里我们也可以添加自定义的用户，并为其分配角色，不同的角色对应不同的功能。


#如果无法从传入请求中提取身份验证令牌，则认为传入请求是匿名的。 默认情况下，拒绝匿名请求并返回身份验证错误（状态代码401）。
#要启用匿名访问，请在elasticsearch.yml配置文件中为匿名用户分配一个或多个角色。 例如，以下配置分配匿名用户role1和role2：
xpack.security.authc:
  anonymous:
    username: anonymous_user 
    roles: role1, role2 
    authz_exception: true 
#匿名用户的用户名/主体。 如果未指定，则默认为_es_anonymous_user。
#与匿名用户关联的角色。 如果未指定角色，则禁用匿名访问 - 将拒绝匿名请求并返回身份验证错误。

#更具体的用户设置及权限设置，可以在kibana的WEB界面下设置：managerment/elasticsearch/security:user&role


#elasticsearch.yml 部分配置说明：
选项参数值为布尔值。true：启用，false禁用
功能名称：文件配置格式：适用组件
图形展示： xpack.graph.enabled：只使用于kibana组件
报表统计： pack.reporting.enabled：只使用于kibana组件
报警通知： xpack.watcher.enabled：只适用于elasticsearch组件
安全认证： xpack.security.enabled：适用于elk的三个组件
监控跟踪： xpack.monitoring.enabled：适用于elk的三个组件
设备资源分配：xpack.ml.enabled：适用于elasticsearch和kibana组件


#查看X-panck过期时间：
curl http://xxx.xxx.xxx.xxx:xxx/_xpack/license

#更新x-pack证书（注册免费许可：https://register.elastic.co/xpack_register）
curl -XPUT -u elastic:changeme 'http://xxx.xxx.xxx.xxx:xxx/_xpack/license?acknowledge=true' -d @license.json

参考：
https://www.cnblogs.com/shaosks/p/7681865.html


