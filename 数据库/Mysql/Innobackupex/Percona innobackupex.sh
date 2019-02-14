#!/bin/bash

# xtrabackup只能备份InnoDB和XtraDB两种数据引擎的数据而不能备份MyISAM数据
# innobackupex封装了xtrabackup。是脚本封装，能同时处理innodb和myisam，但处理myisam时需加读锁

#常规
MYSQL_USER="root"
MYSQL_PASS="123456"
MYSQL_HOST="127.0.0.1"
MYSQL_PORT="3306"
MYSQL_CONF="/etc/my.cnf"
MYSQL_DBPATH="/data"

#完整备份的备份路径
BACKUP_PATH="/db_backup/innobackupex"

#完整备份进行恢复时的恢复路径
FULLBACK_RECOVER_PATH="/db_backup/innobackupex/2017-11-04_20-42-14"

#上次完整备份时的备份目录与用于增量备份的备份目录
INCREMENTAL_BASEDIR="/db_backup/innobackupex/incremental/2017-11-04_19-43-38"
INCREMENTAL_PATH="/db_backup/innobackupex/incremental"

#增量备份进行恢复时的全备路径及其之后所有需恢复的增备路径
INCREMENTAL_LAST_PATH="${BACKUP_PATH}/2017-11-04_20-03-03"
INCREMENTAL_ALL_PATH=(${INCREMENTAL_PATH}/{2017-11-04_20-04-46,2017-11-04_20-06-05,2017-11-04_20-07-08})    #需严格按照增量备份时的顺序写入

mkdir -p {${BACKUP_PATH},${INCREMENTAL_PATH}}

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#依赖
function Install_percona() {
    yum -y install libev numactl
    if [ -s 'percona-release-0.1-3.noarch.rpm' ]; then
        yum -y localinstall percona-release-0.1-3.noarch.rpm
    else
        yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
    fi
    yum -y install percona xtrabackup 
}

#完整备份
function fullback() {
    
    mkdir -p ${BACKUP_PATH}
    
    innobackupex \
    --defaults-file=${MYSQL_CONF} \
    --user=${MYSQL_USER:-root} \
    --password=${MYSQL_PASS:?error}  \
    --host=${MYSQL_HOST} \
    --port=${MYSQL_PORT} \
    ${BACKUP_PATH}
    
}

#完整备份后恢复
function fullback_recover() {

    /etc/init.d/mysqld stop && sleep 1
    
    rm -rf ${MYSQL_DBPATH}/*  #将备份恢复到到数据库时数据库目录要为空
    
    innobackupex  --defaults-file=${MYSQL_CONF} --copy-back ${FULLBACK_RECOVER_PATH}  
    
    if [ "$?" == "0" ];then
        echo "succeed"
    fi
    
    chown -R mysql.mysql ${MYSQL_DBPATH:=/var/lib/mysql}
    
    /etc/init.d/mysqld start

}   

#增量备份
function increase() {

    mkdir -p ${INCREMENTAL_PATH}

    innobackupex \
    --defaults-file=${MYSQL_CONF} \
    --user=${MYSQL_USER:-root} \
    --password=${MYSQL_PASS:?error}  \
    --host=${MYSQL_HOST} \
    --port=${MYSQL_PORT} \
    --incremental ${INCREMENTAL_PATH} \
    --incremental-basedir=${INCREMENTAL_BASEDIR:?error} #上次的备份目录
    
    if [ "$?" == "0" ];then
        echo "succeed"
    fi
    
}

#增量恢复
function increase_recover() {

    /etc/init.d/mysqld stop && sleep 1
    
    rm -rf ${MYSQL_DBPATH}/*  #将备份恢复到到数据库时数据库目录要为空
    
    #日志回滚并合并全备及增量备份数据文件
    innobackupex --defaults-file=${MYSQL_CONF} --apply-log --redo-only ${INCREMENTAL_LAST_PATH}
    
    #合并所有的增量备份
    for recover_path in ${INCREMENTAL_ALL_PATH[@]};
    do
        innobackupex \
        --defaults-file=${MYSQL_CONF} \
        --apply-log --redo-only  ${INCREMENTAL_LAST_PATH} \
        --incremental-dir=${recover_path}
        
        if [ "$?" -ne "0" ];then
            echo "ERROR! @ ${recover_path} recover..."
            exit 1
        fi
        
    done

    #恢复完整备份（此时${INCREMENTAL_LAST_PATH}已包含所有增量，可查看checkpoints核实）
    innobackupex --defaults-file=${MYSQL_CONF} --copy-back ${INCREMENTAL_LAST_PATH}
    
    chown -R mysql.mysql ${MYSQL_DBPATH:=/var/lib/mysql}
    /etc/init.d/mysqld start
    
    if [ "$?" == "0" ];then
        echo "succeed"
    fi
    
}

case $1 in 
    -I|I) 
        Install_percona     #安装percona
    ;;
    -F|F) 
        fullback    #全备
    ;;
    -f|f) 
        increase    #增备
    ;;
    -R|R) 
        fullback_recover    #全备恢复
    ;;
    -r|r) 
        increase_recover    #增备恢复
    ;;
    *)
        echo -e "Install_percona(I)\nfullback(F)\nfullback_recover(R)\nincrease(f)\nincrease_recover(r)"
    ;;
esac 

exit 0

# -------------------------------------------------------------------------------------
# 常用参数：
# --user=                   #指定数据库备份用户
# --password=               #指定数据库备份用户密码
# --port=                   #指定数据库端口
# --host=                   #指定备份主机
# --socket=                 #指定socket文件路径
# --databases=              #备份指定数据库,多个空格隔开，如--databases="dbname1 dbname2",不加备份所有库
# --defaults-file=          #指定my.cnf配置文件
# --apply-log               #日志回滚
# --incremental=            #增量备份，后跟增量备份路径
# --incremental-basedir=    #增量备份，指上次增量备份路径
# --redo-only               #合并全备和增量备份数据文件
# --copy-back               #将备份数据复制到数据库，数据库目录要为空
# --no-timestamp            #生成备份文件不以时间戳为目录名
# --stream=                 #指定流的格式做备份,--stream=tar,将备份文件归档
# --remote-host=user@ip DST_DIR     #备份到远程主机

# 备份目录说明：
# # ls 2016-05-07_23-06-04
# backup-my.cnf：            #记录innobackup使用到mysql参数
# xtrabackup_binary：        #备份中用到的可执行文件
# xtrabackup_checkpoints：   #记录备份的类型、开始和结束的日志序列号
# xtrabackup_logfile：       #备份中会开启1个log copy线程用来监控innodb日志文件（ib_logfile），若修改则复制到此文件
# xtrabackup_binlog_info     #记录二进制日志的文件和日志点，可用于slave同步change master配置

