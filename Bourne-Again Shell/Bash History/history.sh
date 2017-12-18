[root@localhost ~]# grep -v "^$" ip
192.168.1.5 
192.168.1.5 
192.168.1.13 
192.168.1.8 
192.168.1.15 
192.168.1.19 
[root@localhost ~]# < ip awk '!/^$/{ip_count[$1]++}END{for(i in ip_count){print ip_count[i]"\t"i}}' | sort -r  #统计IP出现次数
2       192.168.1.5
1       192.168.1.8
1       192.168.1.19
1       192.168.1.15
1       192.168.1.13

[root@localhost ~]# awk 'BEGIN{print ENVIRON["PATH"];}'
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

[root@localhost ~]# awk 'BEGIN{OFMT="%.3f";print 2/3,123.11111111;}' /etc/passwd   
0.667 123.111
[root@localhost ~]# cat /etc/systemd/logind.conf | sed -E "s/.*(RemoveIPC=)(.*)/\1no/g"
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See logind.conf(5) for details.

[Login]
#NAutoVTs=6
#ReserveVT=6
#KillUserProcesses=no
#KillOnlyUsers=
#KillExcludeUsers=root
#InhibitDelayMaxSec=5
#HandlePowerKey=poweroff
#HandleSuspendKey=suspend
#HandleHibernateKey=hibernate
#HandleLidSwitch=suspend
#HandleLidSwitchDocked=ignore
#PowerKeyIgnoreInhibited=no
#SuspendKeyIgnoreInhibited=no
#HibernateKeyIgnoreInhibited=no
#LidSwitchIgnoreInhibited=yes
#IdleAction=ignore
#IdleActionSec=30min
#RuntimeDirectorySize=10%
RemoveIPC=no
#UserTasksMax=
