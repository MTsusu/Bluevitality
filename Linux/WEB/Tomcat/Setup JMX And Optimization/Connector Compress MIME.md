```xml
<Connector port="8080" protocol="HTTP/1.1"
connectionTimeout="20000"
redirectPort="8181" compression="500"
compressableMimeType="text/html,text/xml,text/plain,application/octet-stream" />

当文件大小>=500bytes时压缩
若文件达到大小但没被压缩那么设置属性compression="on"，否则Tomcat默认是"off"
```
### Demo
```xml
<Connector executor="tomcatThreadPool"
               port="8080" protocol="HTTP/1.1"
               URIEncoding="UTF-8"
               connectionTimeout="30000"
               enableLookups="false"
               disableUploadTimeout="false"
               connectionUploadTimeout="150000"
               acceptCount="300"
               keepAliveTimeout="120000"
               maxKeepAliveRequests="1"
               compression="on"
               compressionMinSize="2048"
               compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain,image/gif,image/jpg,image/png" 
               redirectPort="8443" />
```
