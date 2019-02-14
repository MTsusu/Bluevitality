#### LDAP 备忘 ( 轻量量目录访问协议 )
```txt
目录是一个为查询浏览、搜索而优化的专业分布式数据库，它在逻辑上呈树状结构组织数据，就象Linux/Unix中的文件目录树
目录数据库和关系数据库不同：它有优异的读性能但写性能差且没有事务处理、回滚等复杂功能，不适于存储修改频繁的数据...
LDAP 是从 X.500 目录访问协议的基础上发展过来的，目前版本是 v3.0

目录服务是由目录数据库和一套访问协议组成的系统，以下的信息适合储存在目录内：
    1.企业员工信息，如姓名、电话、邮箱等...
    2.公用证书和安全密钥...
    3.公司的物理设备信息，如服务器，它的IP地址、存放位置、厂商、购买时间等...
    4.用户的账号密码和口令...

目录数据库的特点：
    1.结构在逻辑上用树表示而不是用表格。因此不能用SQL语句
    2.可很快地得到查询结果，不过在写方面慢得多
    3.提供了静态数据的快速查询方式
    4.C/S模式，Client提供操作目录信息树的工具，Server用于存储数据
    5.这些工具可将数据库的内容以文本格式（LDAP 数据交换格式，LDIF）呈现在面前
    6.LDAP是一种开放Internet标准，LDAP协议是跨平台的Interent协议
```
####  Entry 与 Attribute
```txt
条目 Entry:
    也叫记录项，是LDAP中最基本的颗粒，就像字典的词条或数据库的记录。通常对LDAP的增删改查都是以条目为基本对象进行操作的
    每个条目"Entry"，都有着一个唯一的标识名：distinguished Name ----> 简称："DN"
    
    Example： dn："cn=baby,ou=marketing,ou=people,dc=mydomain,dc=org"
    通过dn层次型的语法结构从而可以方便地表示出条目在LDAP树中的位置，它通常用于检索
    
        rdn： 一般指dn逗号最左边部分，如cn=baby。它与RootDN不同（RootDN常与RootPW同时出现并特指管理LDAP的用户）
    Base DN： LDAP目录树的最顶部就是根，即所谓的"Base DN"，如："dc=mydomain,dc=org"

属性 Attribute:
     属性不是随便定义的，需符合一定规则，此规则可通过schema制定（ objectClass的类型 ）
     每个条目都可有很多属性，如常见的人都有姓名、地址、电话等...，每个属性都有名称及对应值并且值可有单或多个...
     LDAP为人员组织机构中常见的对象都设计了属性，如：commonName，surname。
     属性的冒号后面必须留空格，值的后面不能有空格。属性支持高级的过滤功能
    
     常见的属性：
         c：  国家
         l：  地名，如城市或者其他地理区域的名字
         cn： common name，指对象名字。如果指人需要使用其全名（公共名称）
         dc： domain Component，常用来指域名的一部分，如：example.com ---> dc=example,dc=com
         dn:  唯一的辨别名(条目)，类似Linux的绝对路径，对象都有唯一的名称，如："uid=tom,ou=market,dc=example,dc=com"
         rdn: 相对辨别名，类似Linux的相对路径，它是与目录树结构无关的那部分
         sn： surname，指一个人的姓
         mail：电子信箱地址
         telephoneNumber：   电话号码，应该带有所在的国家的代码
         givenName：  名字，但不能用来指姓
         o：   organizationName，指组织的名字
         ou：  organizationalUnitName，指一个组织单元的名字，是容器对象，它可以包含其他的各种对象
         uid： userid，通常指某用户的登录名，与Linux中的用户UID不同

    下面是部分常用的objectClass要求必设的属性：
          account：userid
          organization：o 
          person：cn和sn 
          organizationalPerson：与person相同
          organizationalRole：cn
          organizationUnit：ou 
          posixGroup：cn、gidNumber
          posixAccount：cn、gidNumber、homeDirectory、uid、uidNumber 
```
#### 数据交换格式 LDIF
``` txt
"LDAP Data Interchange Format" 是LDAP数据库信息的一种文本格式，其用于数据的导入/出，其中的每行都是 "属性:值" 对
可以说LDIF文件是OpenLDAP操作数据或修改配置的一切来源...

格式：
    # 条目1注释....
    dn: 条目1
    objectClass：xxx
    属性描述:值
    属性描述:值
    属性描述:值
    
    ......（略）
```
#### 数据交换格式：LDIF
```txt
dn: ou=Marketing, dc=example,dc=com                  #即"dn"，其描述了LDAP的树形结构，相当于关系型数据库中的一行记录
changetype: add                                      #
objectclass: top                                     #通过schema定义条目的属性（即objectClass的作用）
objectclass: organizationalUnit                      #每个条目至少要有一个objectclass
ou: Marketing                                        #K:V（相当于关系型数据库的 各字段值）

dn: cn=Pete Minsky,ou=Marketing,dc=example,dc=com    #
changetype: add                                      #
objectclass: person                                  #通过schema定义条目的属性（即objectClass的作用）
objectclass: organizationalPerson                    #...
objectclass: inetOrgPerson                           #...
cn: Pete Minsky                                      #K:V
sn: Pete                                             #...
ou: Marketing                                        #...
description: sb, sx                                  #...
description: sx                                      #...
uid: pminsky                                         #...
```
#### 常用的 objectClass
```txt
dcobject             #表示一个公司
ipHost               #
alias
organizationalUnit   #表示一个公司/部门
posixAccount         #常用于账户认证
```
