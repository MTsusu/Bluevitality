#ƥ��˳��
hosts.allow,ƥ��ɹ�����У�����ƥ��hosts.deny����֮�Ż�ȥƥ��hosts.deny�������߳�ͻ����hosts.denyΪ׼

��������ժ�Բ��ͣ�http://wordpress.facesoho.com/server/linux-tcp_wrappers.html
�򵥽���һ��tcp-wrapers
һ. ���ȼ��ĳ�ַ����Ƿ���tcp_wrappers ����
ldd `which sshd` grep | libwrap
�����������ӣ�˵��ĳ���������tcp_wrappers����
��. ��tcp_wrappers��ص��ļ���
/etc/hosts.allow
/etc/hosts.deny
��. ����ԭ��
1. ���������Զ�̵��ﱾ����ʱ��
���ȼ��/etc/hosts.allow
����ƥ��ģ���Ĭ���������,���� /etc/hosts.deny����ļ�
û��ƥ���,��ȥƥ��/etc/hosts.deny �ļ�,�����ƥ��ģ���ô�;ܾ��������
2. ������������ļ��У���û��ƥ�䵽��Ĭ����������ʵ�
��. �������ļ���ʽ
�����б� ����ַ�б� ��ѡ��
A. �����б��ʽ������ж��������ô���ö��Ÿ���
B. ��ַ�б��ʽ��
1. ��׼IP��ַ�����磺192.168.0.254��192.168.0.56�������һ���ã�����
2. �������ƣ����磺www.baidu.com����.example.conƥ��������
3. �������룺192.168.0.0/255.255.255.0ָ����������
4. �������ƣ����� @mynetwork
C. ѡ�
��Ҫ��allow �� deny ������ѡ��
D. �������ض���ʽ
ALL ��ָ����������
LOCAL ��ָ����������
KNOWN ���ܹ�������
UNKNOWN �����ܽ�����
PARANOID ��

��. ��չѡ�
spawn : ִ��ĳ������ [spawnԭ���ǲ���]
vsftpd : spawn echo ��login attempt from %c��to %s�� | mail �Cs warning root
twist : �ж������ִ�У�
vsftpd : twist echo ��login attempt from %c to %s �� | mail �Cs waring root

��. һ������
��/etc/hosts.allow�ļ���ָ�����������
vsftpd: 192.168.0.
in.telnetd, protmap: 192.168.0.8
��/etc/hosts.deny��ָ��һ���ļ�
ALL: .cracker.org EXCEPT trusted.cracker.org
vsftpd,protmap: ALL
sshd: 192.168.0. EXCEPT 192.168.0.4

TCP ����Ⱦ���IP���˻���IP Filtering [Linux �ṩ�ĵ�һ�㱣��]

���Խ�����Ҫ����ԴIP(���� TCP ����� Head ����)�ȵ���,���ͨ���ˣ���ȥͨ��TCP_wrappers����,
�������������ͨ����,�ٸ���ÿ��������ʿ����趨 �������ͻ����ܵõ���Ȩ�޺���Ϣ.

TCP_wrappers����ǽ��Ҫ�漰�������ļ�
/etc/hosts.allow
/etc/hosts.deny
�������ļ���������xinetd��.

��Ҫ��װtcp_wrappers�׼�,��Ϊ�������ļ���tcp_wrappers���趨�ļ�,������һ�������ķ���ǽ,
tcp_wrappers�趨tcp��װ�İ��Ƿ���Խ���/etc/hosts.allow��/etc/hosts.deny,
���һ���������ܵ� xinetd �� TCP_Wrappers �Ŀ���ʱ����ô�÷���ͻ������� hosts.allow �� hosts.deny �Ĺ���,

���ж�ĳ�������Ƿ����ʹ��tcp_wrappers����ǽ.vsftpd . telnet .sendmail��sshd��tcpd��xinetd��gdm��portmap������ʹ�á�
�ܶ������/etc/xined.d/Ŀ¼��,���ԶԷ�����й��������.
�鿴һ�������Ƿ������tcp_wraper����:
#ldd  `which  servername`

������Ϣ���кܶ�lib��ͷ�������ļ�[���ļ�],˵���˷�����TCP_Wrapper�������.

�ȿ�#cat /etc/xinetd.conf |less,���enable��disable��Ϊyes,�Ǿ��Ծܾ�����.

only_from #����ֻ��ָ�����������Է��ʸ÷���.
no_access #����ָ�����������ܷ��ʸ÷���.

only_from��no_access ����������а����Ĺ�ϵʱ,��С��Χ��Ϊ��,
����
��only_from��1.1.1.0�����������Է���
��no_access��1.1.0.0�������ܷ���
��ʱ�����Ǿܾ�����,������only_fromΪ׼.

cps #�����������ӽ�����������Ŀ.
per_source #����һ̨�������������Ŀ,ͨ����cps����.
instance #�������������Ŀ,�����Ŀ��ָ��ͬ���������ӽ�������Ŀ,������ͬһ̨�������ӽ�������Ŀ..
bind  #����ָ��������IP��ַ(��ֻ��IP��ַ,����������������.)
baner #���延ӭ��Ϣ,����ָ��һ���ļ�·��.���ļ����ݿ��Լ�����..
socket_type = stream #����ʹ��tcpЭ��..
single_threaded #���嵥�߳�
multi_threaded  #������߳�

��ftp�����telnetΪ��,
��������ֻ��/etc/sysconfig/network�ж���,��������/etc/hosts,�������ļ��еĻ���������һ��,����ʹ������telnet,Ҳ�޷�telnet�ɹ�

������IP:192.168.0.195�Ȱ�װһ��xinetd��,Ȼ��װftp����telnet��.
[root@station195 Server]# rpm -ivh xinetd-2.3.14-10.el5.i386.rpm
[root@station195 Server]# rpm -ivh vsftpd-2.0.5-16.el5.i386.rpm
[root@station195 Server]# rpm -ivh telnet-0.17-39.el5.i386.rpm
[root@station195 Server]# rpm -ivh telnet-server-0.17-39.el5.i386.rpm
�༭/etc/xinetd.d/telnet��disable = yes��Ϊdisable = no(����telnet,Ĭ�ϲ��Ὺ��.)
[root@station195 Server]# service xinetd  restart
[root@station195 Server]# chkconfig xinetd on
�༭hosts.allow�ļ�,д��һ��vsftpd:192.168.0.0/255.255.255.0 EXCEPT 192.168.0.192
�ٱ༭/etc/hosts.deny�ļ�,����һ��vsftpd:ALL,Ȼ��ִ�д�����
[root@station195 ~]# chkconfig �Clevel 35 vsftpd on
[root@station195 ~]# service vsftpd restart

�����õ�¼������ʱ����Ϣ����������,��spawn����.
�༭hosts.allow�ļ�
д��in.telnetd:ALL:spawn /bin/echo `date` %c %d | /bin/mail -s ��somebody access our ftp.��  root
��˼��:�����������ʷ�����ʱ,�����Ա�����ʼ�������somebody access our ftp .
%c��ȡ�ͻ�������Ϣ
%d���ػ����̵�����
.���ͻ���telnet��������,���������Լ����ʼ�,���ǿ����ڷ�������ʹ��mail����鿴����

From myaccount@example.com  Thu Feb 25 14:35:47 2010
Date: Thu, 25 Feb 2010 14:35:47 +0800
From: myaccount <myaccount@example.com>
To: myaccount@example.com
Subject: somebody access our telnet.
Thu Feb 25 14:35:47 CST 2010 192.168.0.192 in.telnetd

�����Ը��Է����һ�ּ���,��ʾ�Է������û���������,���붼��ȷ,���ǽ���ȥ.

�����Ҫ�õ�twist����[������ ����]
ftpΪ��:
�༭hosts.allow�ļ�
���������䣺
vsftpd:ALL:twist /bin/echo   �� welcome to server.��

����FTPʱ�ͻ���ʾ�����û���������,��ʹ����ȷ��.���ǽ���ȥ��.
�����Է��ظ��ͻ�һ�仰,�ȷ�˵��hosts.allow��д��
vsftpd:ALL:twist /bin/echo  `date` ��connection refused by  %s.��
����ftpʱ,ֱ�ӻ��˳���,���ص���Ϣ.
C:\>ftp 192.168.0.195
Connected to 192.168.0.195.
Thu Feb 25 15:15:41 CST 2010 connection refused by vsftpd@192.168.0.195.
Connection closed by remote host.

Ҳ���Խ�spawn��twist����һ����.
��hosts.allow�в���һ�仰
vsftpd:ALL:spawn /bin/echo `date` %c to %s denied. >>/var/log/tcpwrapper.log:twist /bin/echo ��attempt log to %s failed.��
����¼������ʱ�Ὣ������Ϣ����tcpwrapper.log��..
Thu Feb 25 15:32:44 CST 2010 192.168.0.200 to vsftpd@192.168.0.195 denied.
C:\>ftp 192.168.0.195
Connected to 192.168.0.195.
attempt log to vsftpd@192.168.0.195 failed.
Connection closed by remote host.

�����Զ��延ӭ��Ϣbanners
