#### 测试算法性能
```bash
[root@localhost ~]# openssl speed -h
Error: bad option or value

Available values:
md2      md4      md5      hmac     sha1     sha256   sha512   whirlpoolrmd160
idea-cbc seed-cbc rc2-cbc  bf-cbc
des-cbc  des-ede3 aes-128-cbc aes-192-cbc aes-256-cbc aes-128-ige aes-192-ige aes-256-ige 
camellia-128-cbc camellia-192-cbc camellia-256-cbc rc4
rsa512   rsa1024  rsa2048  rsa4096
dsa512   dsa1024  dsa2048
ecdsap256 ecdsap384 ecdsap521
ecdsa
ecdhp256  ecdhp384 ecdhp521
ecdh
idea     seed     rc2      des      aes      camellia rsa      blowfish

Available options:
-elapsed        measure time in real time instead of CPU user time.
-engine e       use engine e, possibly a hardware device.
-evp e          use EVP e.
-decrypt        time decryption instead of encryption (only EVP).
-mr             produce machine readable output.
-multi n        run n benchmarks in parallel.
[root@localhost ~]# openssl speed rsa4096       #指定一种加密算法进行测试
Doing 4096 bit private rsa's for 10s: 
1145 4096 bit private RSA's in 9.25s
Doing 4096 bit public rsa's for 10s: 
75678 4096 bit public RSA's in 9.23s
OpenSSL 1.0.1e-fips 11 Feb 2013
built on: Mon Feb 20 14:38:48 UTC 2017
options:bn(64,64) md2(int) rc4(16x,int) des(idx,cisc,16,int) aes(partial) idea(int) blowfish(idx) 
compiler: gcc -fPIC -DOPENSSL_PIC -DZLIB -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN ..........(略)
                  sign    verify    sign/s verify/s
rsa 4096 bits 0.008079s 0.000122s    123.8   8199.1
```

#### 密码方式的加解密
```bash
#交互式加密
[root@localhost ~]# echo "test" >> secret.txt 

#-e 加密 -in 需加密文件 -out 加密后文件
[root@localhost ~]# openssl enc -des3 -e -in secret.txt -out secret_encrypt.txt 
enter des-ede3-cbc encryption password:                                         #输入密码
Verifying - enter des-ede3-cbc encryption password:                             #验证输入
[root@localhost ~]# cat secret_encrypt.txt 
Salted__

#交互式解密
#-d 解密 -in 需解密文件 -out 解密后文件
[root@localhost ~]# openssl enc -des3 -d -in secret_encrypt.txt -out secret.txt 
enter des-ede3-cbc decryption password:                                         #输入密码
[root@localhost ~]# cat secret.txt 
test

#免交互加解密(-k 指定密码)
[root@localhost ~]# openssl enc -des3 -e -k 123456 -in secret.txt -out secret_encrypt.txt
[root@localhost ~]# openssl enc -des3 -d -k 123456 -in secret_encrypt.txt -out secret.txt   
[root@localhost ~]# cat secret.txt 
test

#打包并加密文件夹
[root@localhost ~]# tar czvf - yincan | openssl des3 -salt -k password -out yincan.tar.gz

#解密并解包文件夹
[root@localhost ~]# openssl des3 -d -k password -salt -in yincan.tar.gz |tar zxvf -

```
#### 非对称密钥方式的加解密
```bash
[root@localhost ~]# cat secret.txt 
test

#生成私钥
[root@localhost ~]# openssl genrsa -out private.key 1024                       
Generating RSA private key, 1024 bit long modulus
.......++++++
...................................................++++++
e is 65537 (0x10001)

#从私钥导出对应的公钥 
[root@localhost ~]# openssl rsa -in private.key -pubout -out public.key         
writing RSA key
unable to load Public Key

#使用公钥加密
[root@localhost ~]# openssl rsautl -encrypt -in secret.txt -inkey public.key -pubin -out secret_encrypt.txt     
[root@localhost ~]# cat secret_encrypt.txt 
G^Gn.1!M(cc}H^%mtdjoIHT;+t[J9;

#使用私钥解密
[root@localhost ~]# openssl rsautl -decrypt -in secret_encrypt.txt -inkey private.key -out secret.txt           
[root@localhost ~]# cat secret.txt 
test
```
