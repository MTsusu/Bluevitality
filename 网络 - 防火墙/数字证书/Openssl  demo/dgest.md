#### 说明
```txt
支持的摘要算法：
    -md5：   默认选项，用md5算法进行摘要
    -md4：   用md4算法进行摘要
    -mdc2：  用mdc2算法进行摘要
    -sha1：  用sha1算法进行摘要
    -sha：   用sha算法进行摘要
    -sha224：    用sha算法进行摘要
    -ripemd160： 用ripemd160算法进行摘要
    -dss1：      用dss1算法进行摘要
    -dss1：      用whirlpool算法进行摘要
    
其他选项：
    -out file：  输出到指定文件
    -c：         打印出两个哈希结果的时候用冒号来分隔开。当设置[-hex]时有效
    -r：         用coreutils格式来输出摘要值
    -rand file： 产生随机数种子的文件(没发现产生实际效果)
    -d：         打印出BIO调试信息值
    -hex：       显示ASCII编码的十六进制摘要结果，默认选项
    -binary：    以二进制的形式来显示摘要结果值
```

#### Example
```bash
#使用sha1算法计算摘要
[root@localhost ~]# echo "123456" >> testfile
[root@localhost ~]# openssl dgst -sha1 testfile 
SHA1(testfile)= c4f9375f9834b4e7f0a528cc65c055702bf5f24a
[root@localhost ~]# echo " " >> testfile 
[root@localhost ~]# openssl dgst -sha1 testfile             #修改内容后摘要值将改变
SHA1(testfile)= 49d9d8586dbe3fdf1252312dad83db89a191e3ff
[root@localhost ~]# openssl dgst -sha1 testfile 
SHA1(testfile)= 49d9d8586dbe3fdf1252312dad83db89a191e3ff
```

#### 签名及验证
```bash
[root@localhost ~]# cat testfile 
123456

#生成公私钥对
[root@localhost ~]# openssl genrsa -out private.key    
Generating RSA private key, 1024 bit long modulus
........................++++++
.......++++++
e is 65537 (0x10001)
[root@localhost ~]# openssl rsa -in private.key -pubout -out public.key        
writing RSA key

#用RSA私钥对SHA1计算得到的摘要值签名并输出到"sha1_rsa_file.sign"
[root@localhost ~]# openssl dgst -sign private.key -sha1 -out sha1_rsa_file.sign testfile

#用相应的公钥和相同的摘要算法进行验签，否则会失败
[root@localhost ~]# openssl dgst -verify public.key -sha1 -signature sha1_rsa_file.sign testfile 
Verified OK
[root@localhost ~]# cat testfile 
123456
```
