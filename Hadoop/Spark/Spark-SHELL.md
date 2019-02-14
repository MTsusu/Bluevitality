#### Demo
```bash
[root@node1 bin]# ./spark-shell 
2018-06-01 19:02:42 WARN  NativeCodeLoader:62 - Unable to load native-hadoop library for your platform... 
using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Spark context Web UI available at http://node1:4040
Spark context available as 'sc' (master = local[*], app id = local-1527850981054).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.3.0
      /_/
         
Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_101)
Type in expressions to have them evaluated.
Type :help for more information.

scala> val days = List("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday") 
days: List[String] = List(Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday)

scala> val daysRDD = sc.parallelize(days)
daysRDD: org.apache.spark.rdd.RDD[String] = ParallelCollectionRDD[0] at parallelize at <console>:26

scala> daysRDD.count()
res0: Long = 7   
```
