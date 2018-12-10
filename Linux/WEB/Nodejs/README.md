#### 说明
```txt
pm2是一个带有负载均衡功能的应用进程管理器，类似有Supervisor，forever

npm install npm -g  #升级npm
npm install pm2 -g  #进程管理

```
#### 启动及查看进程
```txt
# pm2 start app.js
# pm2 start app.js --name my-api    #my-api为PM2进程名称
# pm2 start app.js -i 0             #根据CPU核数启动进程个数
# pm2 start app.js --watch          #实时监控app.js的方式启动，当app.js文件有变动时，pm2会自动reload

# pm2 list
# pm2 show 0 或者 # pm2 info 0      #查看进程详细信息，0为PM2进程id
```
#### 附
```txt
# pm2 monit                         #监控

# pm2 stop all                      #停止PM2列表中所有的进程
# pm2 stop 0                        #停止PM2列表中进程为0的进程

# pm2 reload all                    #重载PM2列表中所有的进程
# pm2 reload 0                      #重载PM2列表中进程为0的进程

# pm2 restart all                   #重启PM2列表中所有的进程
# pm2 restart 0                     #重启PM2列表中进程为0的进程

# pm2 delete 0                      #删除PM2列表中进程为0的进程
# pm2 delete all                    #删除PM2列表中所有的进程

# pm2 logs [--raw]                  #Display all processes logs in streaming
# pm2 flush                         #Empty all log file
# pm2 reloadLogs                    #Reload all logs

# npm install pm2@lastest -g        #安装最新的PM2版本
# pm2 updatePM2                     #升级pm2
```
#### demo
```bash
[root@localhost /]# pm2 list
[PM2] Spawning PM2 daemon with pm2_home=/root/.pm2
[PM2] PM2 Successfully daemonized
┌──────────┬────┬──────┬─────┬────────┬─────────┬────────┬─────┬─────┬──────┬──────────┐
│ App name │ id │ mode │ pid │ status │ restart │ uptime │ cpu │ mem │ user │ watching │
└──────────┴────┴──────┴─────┴────────┴─────────┴────────┴─────┴─────┴──────┴──────────┘
 Use `pm2 show <id|name>` to get more details about an app
```
