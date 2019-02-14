#### 参数及常用模块
```txt
Ansible：
    -f 线程数（任务并发量）
    -i Inventory文件路径（Host List），默认：/etc/ansible/hosts
    -u 以哪个用户身份运行
    -m 指定模块名（默认"command"）
    -e 向playbook中导入变量
    -a 模块相关的参数、命令
    -v 详细模式
    -k 提示输入对端密码（使用密码登陆）
    -K 提示输入对端sudo密码
    -t 将输出放在指定目录，命名为每个主机名称
    -T 超时时长
    -B 在后台运行并在num秒后kill该任务
    --check 仅检测而不执行
    
常用模块： 
    copy、file、cron、group、user、yum、service、script、ping、command、raw、get_url、synchronize

Demo：
检查被控端：     ansible ab* -m ping -f 100 -k
执行命令：       ansible all -a "echo hello"
传输文件：       ansible all -m copy -a "src=/run.sh dest=/"
更改权限：       ansible all -m file -a "dest=/run.sh mode=777 owner=root group=root
执行脚本：       ansible all -m script -a "/run.sh"
安装软件：       ansible zabbix -m yum -a "name=vim state=installed"
启用服务：       ansible apache -m service -a "name=iptables state=running"
创建用户：       ansible mysql -m user -a 'name=linux groups=linux password=foo state=present' --sudo -K
开机自启：       ansible PHP -m service -a 'name=puppet state=restarted enabled=yes'
重启服务：       ansible all -m service -a "name=httpd state=restarted
在v1但不在v2中： ansible v1:!v2
指定Host内的组： ansible -i /etc/ansible/hosts apache -u root -k -m shell -a "ls -l"

内置变量：（ansible在每个主机上执行task时将自动收集目标主机的一些元信息赋给内置变量，查看：ansible <host> -m setup）
    ansible_shell_type
    ansible_python_interpreter #python解释器路径
    ansible_ssh_host
    ansible_ssh_port
    ansible_ssh_user
    ansible_ssh_pass
    ansible_sudo_pass
    ansible_connection
    ansible_ssh_private_key_file

变量优先级：
    1、在命令行中定义的变量（即用-e定义的变量）优先级最高
    2、在inventory中定义的连接变量(比如ansible_ssh_user)
    3、大多数的其它变量(命令行转换,play中的变量,included的变量,role中的变量等)
    4、在Inventory定义的其它变量
    5、由系统通过gather_facts方法发现的Facts
    6、“Role默认变量”, 这个是最默认的值，很容易丧失优先权
```
#### 检查 yaml 语法
```bash
[root@test ~]# ansible-lint playbook.yml 
```
#### 查看模块信息
```bash
[root@test ~]# ansible-doc -l             #查看所有内置模块
a10_server                                Manage A10 Networks AX/SoftAX/Thunder/vThunder devices'  .... 
a10_server_axapi3                         Manage A10 Networks AX/SoftAX/Thunder/vThunder devices             
a10_service_group                         Manage A10 Networks AX/SoftAX/Thunder/vThunder devices' service ....
a10_virtual_server                        Manage A10 Networks AX/SoftAX/Thunder/vThunder devices' virtu ....
accelerate                                Enable accelerated mode on remote node          
aci_aep                                   Manage attachable Access Entity Profile (AEP) on Cisco ACI fabric ....
......（略）
[root@test ~]# ansible-doc -s user        #查看特定模块的说明信息
- name: Manage user accounts
  user:
      append:                # If `yes', will only add groups, not set them to just the ....
      comment:               # Optionally sets the description (aka `GECOS') of user acc....
      createhome:            # Unless set to `no', a home directory will be made for the....
      expires:               # An expiry time for the user in epoch, it will be ignored .... 
      force:                 # When used with `state=absent', behavior is as with `userd....
      generate_ssh_key:      # Whether to generate a SSH key for the user in question. T....
      group:                 # Optionally sets the user's primary group (takes a group n....
      groups:                # Puts the user in  list of groups. When set to the empty s....
      home:                  # Optionally set the user's home directory.
      local:                 # Forces the use of "local" comm
```
#### 使用非对称密钥
```bash
[root@test ~]# ssh-keygen -t rsa -P ''
[root@test ~]# ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.0.3
```
#### ansible-vault
```bash
ansible-vault 
    enctypt  要加密的文件.yaml  将提示输入密码（运行前需解密或指定其密码文件，若需生成解密秘钥需加入相应选项）
    edit     用于编辑经过ansible-vault加密过的文件
    view     查看经过加密的文件
    create   创建一个需要加密的yaml文件
    rekey    重新修已被加密文件的密码
    decrypt  解密文件
```
