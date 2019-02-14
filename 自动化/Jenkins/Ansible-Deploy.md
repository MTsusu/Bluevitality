#### deploy.yaml
```yaml
- hosts: "{{ host_cluster }}"
    vars:
        project_name: "{{ prod_name }}"
    tasks:
        - name: shutdown tomcat of {{ project_name }}
            shell: cd /home/ngquality/shell && sh stop.sh {{ project_name }}
            ignore_errors: true
            tags:
                - dep1
        - name: backup files of {{ project_name }}
            shell: cd /home/ngquality/apps-share/bak && cp {{ project_name }}.war {{ project_name }}.war-`date +"%F-%H-%M-%S"`
            ignore_errors: true
        - name: copy war file to remote host
            copy: src=/home/jenkins/deploy_ngquality/dist/{{ project_name }}.war dest=/home/ngquality/apps-share/bak/
        - name: rm of {{ project_name }}
            shell: cd /home/ngquality/apps-share && rm -rf {{ project_name }}/
        - name: unzip {{ project_name }}.war
            shell: cd /home/ngquality/apps-share/bak && unzip {{ project_name }}.war -d ../{{ project_name }}/
        - name: startup tomcat of {{ project_name }}
            shell: cd /home/ngquality/shell && nohup sh start.sh {{ project_name }} &
            tags:
                - dep2
```
#### 调用 Deploy.yaml 的脚本: ngqualitypfcontrol.sh
```bash
#!/bin/bash

source ~/.bash_profile
cd /home/jenkins/deploy_ngquality/yml

ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol01 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol02 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol03 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol04 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol05 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol06 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol07 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol08 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol09 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol10 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol11 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol12 prod_name='ngqualitypfcontrol'" && \
ansible-playbook deploy.yml -i ./hosts --extra-var "host_cluster=ngqualitypfcontrol13 prod_name='ngqualitypfcontrol'"

exit 0
```
