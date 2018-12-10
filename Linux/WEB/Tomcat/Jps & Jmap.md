#### Example
```bash
[root@localhost bin]# jps                       #查看java进程
98162 Jps
97983 Bootstrap 
[root@localhost ~]# jstack 97983                #查看特定java进程的堆栈信息（-l 附加输出锁相关的信息）
2017-12-14 09:16:44
Full thread dump OpenJDK 64-Bit Server VM (25.151-b12 mixed mode):

"Attach Listener" #29 daemon prio=9 os_prio=0 tid=0x00007f1864000a30 nid=0x5ef waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"ajp-nio-8009-Acceptor-0" #27 daemon prio=5 os_prio=0 tid=0x00007f18a422ce40 nid=0x59a runnable [0x00007f1886e32000]
   java.lang.Thread.State: RUNNABLE
        at sun.nio.ch.ServerSocketChannelImpl.accept0(Native Method)
        at sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:422)
        at sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:250)
        - locked <0x00000000e1222bd0> (a java.lang.Object)
        at org.apache.tomcat.util.net.NioEndpoint$Acceptor.run(NioEndpoint.java:682)
        at java.lang.Thread.run(Thread.java:748)

"ajp-nio-8009-ClientPoller-1" #26 daemon prio=5 os_prio=0 tid=0x00007f18a422b9d0 nid=0x599 runnable [0x00007f1886f33000]
   java.lang.Thread.State: RUNNABLE
        at sun.nio.ch.EPollArrayWrapper.epollWait(Native Method)
        at sun.nio.ch.EPollArrayWrapper.poll(EPollArrayWrapper.java:269)
        at sun.nio.ch.EPollSelectorImpl.doSelect(EPollSelectorImpl.java:93)
        at sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:86)
..............................（略）
[root@localhost bin]# jmap -heap 97983          #查看JVM设置与堆状态...（没放war，报了错）此命令非常有用!....
Attaching to process ID 21711, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 20.10-b01
 
using thread-local object allocation.
Parallel GC with 4 thread(s)
 
Heap Configuration:
   MinHeapFreeRatio = 40
   MaxHeapFreeRatio = 70
   MaxHeapSize      = 2067791872 (1972.0MB)
   NewSize          = 1310720 (1.25MB)
   MaxNewSize       = 17592186044415 MB
   OldSize          = 5439488 (5.1875MB)
   NewRatio         = 2
   SurvivorRatio    = 8
   PermSize         = 21757952 (20.75MB)
   MaxPermSize      = 85983232 (82.0MB)
 
Heap Usage:
PS Young Generation
Eden Space:
   capacity = 6422528 (6.125MB)
   used     = 5445552 (5.1932830810546875MB)
   free     = 976976 (0.9317169189453125MB)
   84.78829520089286% used
From Space:
   capacity = 131072 (0.125MB)
   used     = 98304 (0.09375MB)
   free     = 32768 (0.03125MB)
   75.0% used
To Space:
   capacity = 131072 (0.125MB)
   used     = 0 (0.0MB)
   free     = 131072 (0.125MB)
   0.0% used
PS Old Generation
   capacity = 35258368 (33.625MB)
   used     = 4119544 (3.9287033081054688MB)
   free     = 31138824 (29.69629669189453MB)
   11.683876009235595% used
PS Perm Generation
   capacity = 52428800 (50.0MB)
   used     = 26075168 (24.867218017578125MB)
   free     = 26353632 (25.132781982421875MB)
   49.73443603515625% used
   ....
```
#### Demo
```txt
Jps：
   -q 不输出类名、Jar名和传入main方法的参数
   -m 输出传入main方法的参数
   -l 输出main类或Jar的全限名
   -v 输出传入JVM的参数

Jmap：
   

```
