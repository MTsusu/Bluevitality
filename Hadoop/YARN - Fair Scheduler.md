### YARN的公平调度器配置
```txt
YARN的公平调度器由facebook贡献，适合于多用户共享集群的环境的调度器，其吞吐率高于FIFO调度...
假设在生产环境的Yarn中共有四类用户需要使用集群：开发用户、测试用户、业务1用户、业务2用户
为使他们提交的任务不受影响，我们在Yarn上规划配置了五个资源池，分别为：
    1、dev_group（开发用户组资源池）
    2、test_group（测试用户组资源池）
    3、business1_group（业务1用户组资源池）
    4、business2_group（业务2用户组资源池）
    5、default（只分配了极少资源）
    并根据实际业务情况，为每个资源池分配了相应的资源及优先级等
    这样每个用户组下的用户提交任务时候，会到相应的资源池中，而不影响其他业务
    
```
#### 使用公平调度器: vim etc/hadoop/yarn-site.xml
```xml
<!-- 启用的资源调度器的主类，目前可用的有FIFO、Capacity Scheduler和Fair Scheduler -->
<property>
    <name>yarn.resourcemanager.scheduler.class</name> 
    <!-- <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value> -->
    <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
</property>
<!-- 指定YARN调度器配置文件名，默认就是 "fair-scheduler.xml"
<property>
     <name>yarn.scheduler.fair.allocation.file</name> 
     <value>/hadoop/etc/hadoop/fair-scheduler.xml</value> 
</property>
-->
```
#### ResourceManager 的 fair-scheduler.xml (HADOOP_HOME/conf/fair-scheduler.xml.template)
```xml
<?xml version="1.0"?>
<allocations>  
    <queue name="root">
        <!-- 可向队列中提交应用程序的Linux用户或用户组列表，默认为"*"，即任何用户均可向该队列提交应用程序
        配置该属性时，用户或组之间用"，"分割，用户和用户组之间用空格分割，比如"user1,user2 group1,group2" -->
        <aclSubmitApps> </aclSubmitApps>
        <!-- 该队列的管理员列表，一个队列的管理员可管理该队列中的资源和应用程序，比如可杀死任意应用程序 -->
        <aclAdministerApps> </aclAdministerApps>
        
        <queue name="default"> <!-- 队列名 -->
            <minResources>2000mb,1vcores</minResources> <!-- 最小资源 -->
            <maxResources>10000mb,1vcores</maxResources> <!-- 最大资源 -->
            <maxRunningApps>6</maxRunningApps> <!-- 同时运行作业数，可防止超量Mapper同时运行时的中间输出撑爆磁盘 -->
            <schedulingMode>fair</schedulingMode> <!-- 队列内部调度策略 -->
            <weight>0.5</weight> <!-- 权值 ( 以非比例的方式与其它资源池共享集群 )-->
            <aclSubmitApps>*</aclSubmitApps>
        </queue>
             
        <queue name="dev_group">
            <minResources>200000mb,33vcores</minResources>
            <maxResources>300000mb,90vcores</maxResources>
            <maxRunningApps>150</maxRunningApps>
            <schedulingMode>fair</schedulingMode>
            <weight>2.5</weight>
            <aclSubmitApps>dev_group</aclSubmitApps>
            <aclAdministerApps>hadoop,root</aclAdministerApps>
        </queue>
        
        <queue name="test_group">
            <minResources>70000mb,20vcores</minResources>
            <maxResources>95000mb,25vcores</maxResources>
            <maxRunningApps>60</maxRunningApps>
            <schedulingMode>fair</schedulingMode>
            <weight>1</weight>
            <aclSubmitApps>test_group</aclSubmitApps>
            <aclAdministerApps>hadoop,root</aclAdministerApps>
        </queue>
                                                                                
        <queue name="business1_group">
            <minResources>75000mb,15vcores</minResources>
            <maxResources>100000mb,20vcores</maxResources>
            <maxRunningApps>80</maxRunningApps>
            <schedulingMode>fair</schedulingMode>
            <weight>1</weight>
            <aclSubmitApps>business1_group</aclSubmitApps>
            <aclAdministerApps>hadoop,root</aclAdministerApps>
        </queue>
            <queue name="business2_group">
                <minResources>75000mb,15vcores</minResources>
                <maxResources>102400mb,20vcores</maxResources>
                <maxRunningApps>80</maxRunningApps>
                <schedulingMode>fair</schedulingMode>
                <weight>1</weight>
                <aclSubmitApps>business2_group</aclSubmitApps>
                <aclAdministerApps>hadoop,root</aclAdministerApps>
            </queue>
    </queue>
    
  <queuePlacementPolicy>
      <rule name="primaryGroup" create="false" />
      <rule name="secondaryGroupExistingQueue" create="false" />
      <rule name="default" />
  </queuePlacementPolicy>
 
</allocations>
```
```txt
需要注意的是，所有客户端提交任务的用户和用户组的对应关系需要维护在ResourceManager上
ResourceManager在分配资源池时候，是从ResourceManager上读取用户和用户组的对应关系的，否则就会被分配到default资源池
在日志中出现”UserGroupInformation: No groups available for user”类似的警告。而客户端机器上的用户对应的用户组无关紧要
```
#### 使调度修改生效
```bash
#每次在ResourceManager上新增用户或者调整资源池配额后，需要执行下面的命令刷新使其生效
yarn rmadmin -refreshQueues
yarn rmadmin -refreshUserToGroupsMappings

```
