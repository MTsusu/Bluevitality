#### 测试环境：Tomcat8，以下的变量定义添加在catalina.sh的96行之下（具体百度）
```
# 变量说明：
# $JAVA_OPTS：     仅对启动运行Tomcat实例的Java虚拟机有效
# $CATALINA_OPTS： 对本机上的所有Java虚拟机有效

# JVM初始分配的内存由-Xms指定,默认是物理内存的1/64
# JVM最大分配的内存由-Xmx指定,默认是物理内存的1/4
# 默认空余堆内存小于40%时,JVM就会增大堆直到-Xmx的最大限制，空余堆内存大于70%时, JVM会减少堆直到-Xms的最小限制
# 因此服务器一般设置-Xms,-Xmx相等以避免在每次GC 后调整堆的大小

JAVA_OPTS="
$JAVA_OPTS
-server 
-Xms256M        初始堆，默认1/64
-Xmx512M        最大堆，默认1/4
-Xss1M
-Djava.awt.headless=true 
-Dfile.encoding=UTF-8
-Duser.country=CN
-Duser.timezone=Asia/Shanghai
-XX:MinHeapFreeRatio=80 
-XX:MaxHeapFreeRatio=80 
-XX:ThreadStackSize=512
-XX:NewSize=256m                年轻代大小
-XX:NewRatio=4                  年轻代和年老代的比值.如:为3,表示年轻代与年老代比值为1:3,年轻代占整个年轻代年老代和的1/4
-XX:MaxPermSize=n               持久代大小
-XX:SurvivorRatio=8
-XX:+AggressiveOpts"

收集器设置:
串行收集器:          -XX:+UseSerialGC
并行收集器:          -XX:+UseParallelGC
并行年老代收集器:       -XX:+UseParalledlOldGC
并发收集器:          -XX:+UseConcMarkSweepGC

#或，使用环境变量的方式调整：export $CATALINA_OPTS="-Xmx256m ......"
```

![JVM](资料/JVM.png)
