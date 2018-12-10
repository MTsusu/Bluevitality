```bash
[root@localhost ~]# wget http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dc\
bf/jdk-8u151-linux-x64.tar.gz
[root@localhost ~]# tar -zxf jdk-8u151-linux-x64.tar.gz -C /usr/local/
[root@localhost ~]# ll /usr/local/jdk1.8.0_151/
总用量 25948
drwxr-xr-x. 2 10 143     4096 9月   6 10:29 bin
-r--r--r--. 1 10 143     3244 9月   6 10:29 COPYRIGHT
drwxr-xr-x. 4 10 143     4096 9月   6 10:29 db
drwxr-xr-x. 3 10 143     4096 9月   6 10:29 include
-rwxr-xr-x. 1 10 143  5200672 9月   6 02:47 javafx-src.zip
drwxr-xr-x. 5 10 143     4096 9月   6 10:29 jre
drwxr-xr-x. 5 10 143     4096 9月   6 10:29 lib
-r--r--r--. 1 10 143       40 9月   6 10:29 LICENSE
drwxr-xr-x. 4 10 143       44 9月   6 10:29 man
-r--r--r--. 1 10 143      159 9月   6 10:29 README.html
-rw-r--r--. 1 10 143      526 9月   6 10:29 release
-rw-r--r--. 1 10 143 21115360 9月   6 10:29 src.zip
-rwxr-xr-x. 1 10 143    63933 9月   6 02:47 THIRDPARTYLICENSEREADME-JAVAFX.txt
-r--r--r--. 1 10 143   145180 9月   6 10:29 THIRDPARTYLICENSEREADME.txt

[root@localhost ~]# cat /etc/profile.d/jdk1.8.0_151.sh
JAVA_HOME=/usr/local/jdk1.8.0_151
CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME
export CLASSPATH
export PATH

[root@localhost ~]# source /etc/profile         #载入
[root@localhost ~]# java -version               #验证
java version "1.8.0_151"
Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)
```
#### .bash_profile
```bash
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
export JAVA_HOME=/home/aiuap/jdk
export CLASSPATH=.${JAVA_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
export LANG=zh_CH.UTF-8
```
