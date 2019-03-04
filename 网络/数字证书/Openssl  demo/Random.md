#### 参数说明
```txt
选项说明：
-out file：      结果输出到file中。
-rand  file(s)： 指定随机数种子文件，多个文件间用分隔符分开，windows用";"，OpenVMS用","，其他系统用"："
-base64：        输出结果为BASE64编码数据。
-hex：           输出结果为16进制数据。
num：            随机数长度。
```

#### 使用hex或base64对指定长度的随机数进行编码
```bash
[root@localhost ~]# openssl rand -hex 20
d0541ad8444c082b5ceb340ef4450b61f685198b
[root@localhost ~]# openssl rand -base64 20
EqJwNTmctdKL6M3TC/oT7d1j2Y4=
```