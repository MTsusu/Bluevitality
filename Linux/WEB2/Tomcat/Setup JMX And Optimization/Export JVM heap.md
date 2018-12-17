##### 崩溃时导出JVM的heap信息
```bash
JAVA_OPTS="$JAVA_OPTS -server \
-Xms3G -Xmx3G -Xss256k -XX:PermSize=128m -XX:MaxPermSize=128m \
-XX:+UseParallelOldGC \
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=/tmp/dump
-XX:+PrintGCDetails \
-XX:+PrintGCTimeStamps \
-Xloggc:/usr/aaa/dump/heap_trace.txt \
-XX:NewSize=1G -XX:MaxNewSize=1G"

#说明:
#-XX:+HeapDumpOnOutOfMemoryError 可以让JVM在出现内存溢出时Dump出当前的内存转储快照。
#通过用jmap生产dump文件：jmap -dump:format=b,file=HeapDump.bin <pid>

#更小的年轻代必然导致更大年老代，小的年轻代会导致普通GC很频繁，但每次的GC时间会更短；大的年老代会减少Full GC的频率
#更大的年轻代必然导致更小的年老代，大的年轻代会延长普通GC的周期，但会增加每次GC的时间；小的年老代会导致更频繁的Full GC
```
