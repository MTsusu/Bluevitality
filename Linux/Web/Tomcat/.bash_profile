# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
export JAVA_HOME=/home/aiuap/jdk
export CLASSPATH=.${JAVA_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
export LANG=zh_CH.UTF-8
