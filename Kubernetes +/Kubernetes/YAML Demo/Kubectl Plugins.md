```bash
#插件只不过是一个独立的可执行文件，但要求其名称需以 "kubectl-" 开头。要安装插件，只需将此可执行文件移动到$PATH路径内即可。


#在PATH中搜索有效的插件可执行文件，执行此命令会导致遍历PATH中的所有以kubectl-开头的文件
[root@localhost ~]# kubectl plugin list

#注：可使用任何允许编写命令行命令的编程语言或脚本编写插件!
#插件会继承kubectl二进制文件的环境。插件根据其文件名确定其实际的命令格式，如：插件 "kubectl-foo" 的命令格式为：kubectl foo

[root@localhost bin]# cat > kubectl-foo <<'EOF'
#!/bin/bash

if [[ "$1" == "version" ]]  # optional argument handling
then
    echo "1.0.0"
    exit 0
fi

if [[ "$1" == "config" ]]   # optional argument handling
then
    echo $KUBECONFIG
    exit 0
fi

echo "I am a plugin named kubectl-foo"
EOF

[root@localhost bin]# chmod +x ./kubectl-foo

#测试：
[root@localhost bin]# kubectl foo
I am a plugin named kubectl-foo
[root@localhost bin]# kubectl foo version
1.0.0
[root@localhost bin]# export KUBECONFIG=~/.kube/config
[root@localhost bin]# kubectl foo config
/home/<user>/.kube/config

[root@localhost bin]# KUBECONFIG=/etc/kube/config ; kubectl foo config
/etc/kube/config

# 说明：
# kubectl-foo-bar-baz：
# 在用户调用命令的情况下，如："kubectl foo bar baz arg1 --flag=value arg2" ，插件机制将首先尝试找到具有最长名称的插件
# 在这种情况下，该插件将是kubectl-foo-bar-baz-arg1。
# 一旦找不到该插件，会将最后一个以破折号分隔的值视为参数（在本例中为arg1），并尝试查找下一个最长的名称，kubectl-foo-bar-baz。
# 在找到具有此名称的插件后将会调用该插件，并将其名称后面所有args和标志传递给插件可执行文件。
# 插件机制总是会选择给定用户的指令可能最长的插件名称
```