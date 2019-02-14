#!/bin/bash
#be in common use . by wy

MYSQL_USERNAME="root"
MYSQL_PASSWORD="123456"
MYSQL_HOST="127.0.0.1"
MYSQL_PORT="3306"
BACKUP_HOME="/data/db_backup"

mkdir -p ${BACKUP_HOME:?error}

mysqldump -u ${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} \
--default-character-set=UTF8 \
--single-transaction \
--delete-master-logs \
--master-data=2 \
--all-databases \
--add-drop-database \
--add-drop-table \
--add-drop-trigger \
--flush-logs \
--flush-privileges \
--ignore-table=mysql.user \
--routines \
--events \
> ${BACKUP_HOME:?error}/mysql_db_backup.$(date +%Y%m%d).sql

echo -e "\nScript Execution Time： \033[32m${SECONDS}s\033[0m"

exit 0
