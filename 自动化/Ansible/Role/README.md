#### 组织结构
```bash
[root@test ~]# tree lnmp/
lnmp/
|-- hosts
|-- mysql
|   |-- files
|   |-- handlers
|   |-- meta
|   |-- tasks
|   |-- templates
|   `-- vars
|-- nginx
|   |-- files
|   |-- handlers
|   |-- meta
|   |-- tasks
|   |-- templates
|   `-- vars
`-- run.yml
```
#### 组织格式
```bash
[root@test ~]# ansible-playbook -i ./hosts   run.yml  #执行

[root@test ~]# cat lnmp/hosts   # Like Inventory
[nginx]
192.168.0.1

[mysql]
192.168.0.2
192.168.0.3

[root@test ~]# cat lnmp/run.yml 
---
- name: install httpd
  hosts: all
  user: root
  roles:
    - apache       #会调用roles/lnmp/tasks/main.yml ' - {role: apache,tags:{'delete_httpd'}} '
- name: install mysql
  hosts: all
  roles:
    - mysql
    
[root@test ~]# cat lnmp/nginx/tasks/main.yml
- name: install nginx
  yum: name=nginx  state=present
  notify:
    - restart nginx
    - restart iptables
   #- include: delete_httpd.yml
   #会调用、roles/nginx/handlers/main.yml文件里对应name为restart nginx和restart iptables的相应命令并执行
   #若之前nginx服务已安装，再次执行，notify无法触发

[root@test ~]# cat lnmp/nginx/handlers/main.yml
---
 - name: restart nginx
   service: name=nginx  state=restarted
 - name: restart iptables
   service: name=iptables  state=restarted
```
