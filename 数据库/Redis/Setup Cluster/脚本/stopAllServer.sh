#!/bin/sh  
cd 7000
ls
./redis-cli -p 7000 shutdown
cd ..

cd 7001
ls
./redis-cli -p 7001 shutdown
cd ..

cd 7002
ls
./redis-cli -p 7002 shutdown
cd ..

cd 7003
ls
./redis-cli -p 7003 shutdown
cd ..


cd 7004
ls
./redis-cli -p 7004 shutdown
cd ..

cd 7005
ls
./redis-cli -p 7005 shutdown
cd ..
