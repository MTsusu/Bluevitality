#!/bin/bash
SERVICE_TOKEN="745d92cbf407ac05ef36366fcbd8a42d"
TITLE=$1
MESSAGE=$2
 
CONTENT=$TITLE-$MESSAGE
 
DATA="{content: \"$CONTENT\"}"


curl -H "servicetoken:$SERVICE_TOKEN" -X POST -d "$DATA" http://www.linkedsee.com/alarm/zabbix

