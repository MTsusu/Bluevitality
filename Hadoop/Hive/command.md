```txt
创建表一般有几种方式：
    create table 方式：以上例子中的方式。
    create table as select 方式：根据查询的结果自动创建表，并将查询结果数据插入新建的表中。
    create table like tablename1 方式：是克隆表，只复制tablename1表的结构。

hive> create table if not exists userinfo   
    > (
    >   userid int,
    >   username string,
    >   cityid int,
    >   createtime date    
    > )
    > row format delimited fields terminated by '\t'
    > stored as textfile;
    OK
    Time taken: 2.133 seconds

说明：
如果表不存在，就创建表userinfo
指定列之间的分隔符：  row format delimited fields terminated by '\t'
指定文件存储格式为textfile：  stored as textfile
 ```
 
 #### 创建外部表
 ```txt
外部表是没有被hive完全控制的表，当表删除后，数据不会被删除。

hive> create external table iislog_ext (
    >  ip string,
    >  logtime string    
    > )
    > ;
 ```
 #### 创建分区表
 ```txt
Hive查询一般是扫描整个目录，但是有时候我们关心的数据只是集中在某一部分数据上
比如一个Hive查询往往是只是查询某天的数据，这样的情况下，可以使用分区表来优化，1天是1个分区，查询时只扫描指定天分区的数据

普通表和分区表的区别在于1个Hive表在HDFS上是有1个对应的目录来存储数据
普通表的数据直接存储在这个目录下，而分区表数据存储时，是再划分子目录来存储的。一个分区一个子目录。主要作用是来优化查询性能

--创建经销商操作日志表
create table user_action_log
(
companyId INT comment   '公司ID',
userid INT comment   '销售ID',
originalstring STRING comment   'url', 
host STRING comment   'host',
absolutepath STRING comment   '绝对路径',
query STRING comment   '参数串',
refurl STRING comment   '来源url',
clientip STRING comment   '客户端Ip',
cookiemd5 STRING comment   'cookiemd5',
timestamp STRING comment   '访问时间戳'
)
partitioned by (dt string)
row format delimited fields terminated by ','
stored as textfile;

这个例子中，这个日志表以dt字段分区，dt是个虚拟的字段，dt下并不存储数据，而是用来分区的
实际数据存储时，dt字段值相同的数据存入同一个子目录中
插入数据或者导入数据时，同一天的数据dt字段赋值一样，这样就实现了数据按dt日期分区存储
当Hive查询数据时，如果指定了dt筛选条件，那么只需要到对应的分区下去检索数据即可，大大提高了效率。
所以对于分区表查询时，尽量添加上分区字段的筛选条件。
```
#### 向Hive中加载数据
```txt
可以将本地文本文件内容批量加载到Hive表中，要求文本文件中的格式和Hive表的定义一致，包括：字段个数、字段顺序、列分隔符。

load data local inpath '/home/hadoop/userinfodata.txt' overwrite into table user_info;

local关键字表示源数据文件在本地，源文件可以在HDFS上，如果在HDFS上，则去掉local
inpath后面的路径是类似”hdfs://namenode:9000/user/datapath”这样的HDFS上文件的路径
overwrite关键字表示如果hive表中存在数据，就会覆盖掉原有的数据。如果省略overwrite，则默认是追加数据。
```
#### 加载到分区表
```txt
load data local inpath '/home/hadoop/actionlog.txt' overwrite into table user_action_log 
PARTITION (dt='2017-05-26');

partition 是指定这批数据放入分区2017-05-26中
```
