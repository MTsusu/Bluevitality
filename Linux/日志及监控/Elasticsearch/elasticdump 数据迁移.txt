tar -zxf node-v8.1.4-linux-x64.tar.gz 
ln -sv node-v8.1.4-linux-x64 node

vi ~/.bash_profile
NODE_HOME=/root/node
PATH=$NODE_HOME/bin:$PATH:$HOME/bin
export NODE_HOME
export PATH


#软件
/root/node/node_modules/.bin/elasticdump

./elasticdump  --input=http://192.168.1.1:9200/original --output=http://192.168.1.2:9200/newCopy --type=mapping  
./elasticdump  --input=http://192.168.1.1:9200/original --output=http://192.168.1.2:9200/newCopy --type=data

#如果索引很多，你还是懒得一个个去迁移，那么你可以改用这个命令
#加个--all=true，input与output里不需要把索引名加上，这样就可以自动把原机器上的所有索引迁移到目标机器
./elasticdump  --input=http://192.168.1.1:9200/ --output=http://192.168.1.2:9200/ --all=true  

elasticdump \
  --input=http://production.es.com:9200/my_index \
  --output=/data/my_index_mapping.json \
  --type=mapping
  
elasticdump \
  --input=http://production.es.com:9200/my_index \
  --output=/data/my_index.json \
  --type=data
