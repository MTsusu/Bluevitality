#!/bin/bash
# CentOS 7.3

#定义...
PYTHON_PATH="/usr/local/python3.6"

set -e
set -x

#身份检查
if [ $(id -u) != "0" ]; then
    echo "error: user must be an administrator"
    exit;
fi

#依赖
yum -y install gcc gcc-c++ ncurses-devel cmake zlib zlib-devel openssl-devel \
bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel

#判断是否有源码包
[ -s Python-3.6.3.tar.gz ] || exit 1
tar -zxvf Python-3.6.3.tar.gz
cd Python-3.6.3
./configure --prefix=${PYTHON_PATH} --enable-optimizations
NUM=$( awk '/processor/{NUM++};END{print NUM}' /proc/cpuinfo )
if [ $NUM -gt 1 ] ;then
    make -j $NUM
else
    make
fi
make install

ln -s ${PYTHON_PATH}/bin/python3.6 /usr/bin/python3.6
ln -s ${PYTHON_PATH}/bin/pip3 /usr/bin/pip3
ln -s ${PYTHON_PATH}/bin/pyvenv-3.6 /usr/bin/pyvenv3

function move_old() {
    cd /usr/bin
    mv python python.bak
    mv pip pip.bak
    
    files=(yum yum-config-manager yum-debug-restore yum-groups-manager yum-builddep yum-debug-dump yumdownloader \
    '/usr/bin/gnome-tweak-tool' '/usr/libexec/urlgrabber-ext-down')
    for file in ${files[@]}
    do
        sed -i "s|#!/usr/bin/python|#!/usr/bin/python.bak|" $file
        echo "fix $file to use old python version..."
    done
    
    mv python3 python
    mv pip3 pip
    mv pyenv3 pyenv
}

#move_old   #将旧版本替换并尽量保持py2对其他软件的的兼容性

export PATH="$PATH:${PYTHON_PATH}/bin"

exit 0
