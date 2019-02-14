#!/usr/bin/python
# -*- coding: UTF-8 -*-

# By Wangyu @ 2019.1.19
# Email: wangyu10@asiainfo.com
# Ansible Module Path: /usr/lib/python2.7/site-packages/ansible/modules/system

import time
import os
import sys
import json
import shlex
import datetime
from multiprocessing import cpu_count

args_file = sys.argv[1]
args_data = file(args_file).read()
arguments = shlex.split(args_data)

def get_load():
    f = open("/proc/loadavg")
    loadstate=f.read().split()
    return loadstate

XARGS="| xargs -n 200 -I {} echo -n {}' '"

Result=json.dumps({  
      "CPU_Load"            : str(get_load()),
      "CPU_numbers"         : str(cpu_count()),
      "/home Use space"     : os.popen("df -h | grep /home$ | awk '{print $(NF-1)}'" + XARGS).read(),
      "/home Total space"   : os.popen("df -h | grep /home$ | awk '{print $(NF-4)}'" + XARGS).read(),
      "/Data Use space"     : os.popen("df -h | grep /data | awk '{print $(NF-1)}'" + XARGS).read(),
      "/Data Total space"   : os.popen("df -h | grep /data | awk '{print $(NF-4)}'" + XARGS).read(),
      "Memory Total"        : os.popen("free -m | grep ^Mem | awk '{print $2\"M\"}'" + XARGS).read(),
      "Memory Use"          : os.popen("free -m | grep ^Mem | awk '{print $3\"M\"}'" + XARGS).read(),
      "Memory Free"         : os.popen("free -m | awk '/^Mem/{print ($2-$3)/$2*100\"%\"}'" + XARGS).read(),
      "Host Run Time"       : os.popen("uptime | awk -F ',' '{print $1,$2}'" + XARGS).read(),
      "Host User List"      : os.popen("ls -l /home | awk 'NR>=2{print $NF}'| xargs -n 100 -I {} echo -n {}' '").read(),
      "Process Count"       : os.popen("ps -ef | wc -l" + XARGS).read(),
      "Program:"            : os.popen("ps -ef | grep -i xmx | grep -oP \"(?<=$HOME/).*?(?=/)\" | sort -u | grep -v jdk | xargs -n 20 -I {} echo -n {}' '").read()
})

#等加闭包
def echo_json():
    return Result

def exec_shell(args="sh -c \"%s\""):
    #print len(arguments)
    #print arguments
    #print arguments.values()
    #print arguments.keys()

    for v in arguments:
        if len(arguments) <= 12:
             print echo_json()
             return sys.exit(0)
    for arg in arguments:
        if "=" in arg:
            (key, shell_command) = arg.split("=")
            if key == "sh":
                rc = os.system( args % str(shell_command))
                if rc != 0:
                    print json.dumps({
                            "failed" : True,
                            "msg"    : "failed setting the time"
                            })
                    sys.exit(1)
                date = str(datetime.datetime.now())
                print json.dumps({
                    "time" : date,
                    "changed" : True
                })
                sys.exit(0)

if __name__ == "__main__":
    exec_shell()
