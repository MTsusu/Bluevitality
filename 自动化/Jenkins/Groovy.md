#### Dynamic Choice Parameter 1
```txt
#通过Groovy脚本来抓取Git仓库的所有Branch并作为一个多选项，方便在最终Build前去选择需要的产品Branch

def gettags = ("git ls-remote -h git@git.showerlee.com:showerlee/phpcms.git").execute()  
gettags.text.readLines().collect { it.split()[1].replaceAll('refs/heads/', '')  }.unique() 
```
```txt
def ver_keys = [ 'bash', '-c', 'cd /gitrepos/project1; git pull>/dev/null; git branch -a|grep remotes|grep release|cut -d "/" -f3|sort -r |head -10 ' ]
ver_keys.execute().text.tokenize('\n')
```
#### Dynamic Choice Parameter 2
```txt
----------------------------- Multi-line string parameter
Name: tomcat_excel

Default Value:
ip moudle moudle_path shutdown_port http_port https_port ajp_port rmi_port dubbo_port
----------------------------- pipline scripts
node {
    def text = "${tomcat_excel}"
    def lines = text.split('\n')
    for (int i=0;i<lines.size();i++) {
        a=lines[i].split('\t')
        stage a[0]
        command = 'cd /home/jenkins/deploy_zhongjianjian' +' && '
        command = command + 'ansible-playbook zhongjianjian.yaml -e'
        command = command + '"ip='+a[0]+' moudle='+a[1]+' moudle_path='+a[2]+' shoutdown_port='+a[3]+' http_port='+a[4]+' 
        https_port='+a[5]+' ajp_port='+a[6]+' rmi_port='+a[7]+' dubbo_port='+a[8]+' role=tomcat"'
        sh command
    }
}
```
#### 调用本地命令
```txt
Process p = "cmd /c dir".execute()  
println "${p.text}"  
```
