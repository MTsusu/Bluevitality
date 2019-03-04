#!/bin/bash

sysctl -w fs.inotify.max_queued_events="99999999"
sysctl -w fs.inotify.max_user_watches="99999999"
sysctl -w fs.inotify.max_user_instances="65535"
sysctl -p 

if [ ! -f /etc/1.pas ]; then
    echo "123456" > /etc/1.pas
    chmod 600 /etc/1.pas
fi

log=/usr/local/inotify/logs/rsync.log

user=root
host1=192.168.225.131
host2=192.168.225.132

src=/home/
des=/home/

inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %e %w%f' -e move,modify,delete,create,attrib ${src} | while read events
{
    echo "events"
    rsync -vzrtopg --delete -e 'ssh -p 22' ${src} ${user}@${host1}:${des} && echo "$(date '+%F') - ${events}" >> $log
    rsync -vzrtopg --delete -e 'ssh -p 22' ${src} ${user}@${host2}:${des} && echo "$(date '+%F') - ${events}" >> $log
}
