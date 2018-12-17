#### Example
```txt
Listen 443 
SSLPassPhraseDialog buildin 
#SSLPassPhraseDialog exec:/path/to/program 
SSLSessionCache dbm:/usr/local/apache2/logs/ssl_scache 
SSLSessionCacheTimeout 300 
SSLMutex file:/usr/local/apache2/logs/ssl_mutex 

<VirtualHost _default_:443> 

# General setup for the virtual host 
DocumentRoot "/usr/local/apache2/htdocs" 
ServerName www.example.com:443 
ServerAdmin you@example.com 
ErrorLog /usr/local/apache2/logs/error_log 
TransferLog /usr/local/apache2/logs/access_log 

SSLEngine on 
SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL 

SSLCertificateFile /usr/local/apache2/conf/ssl.crt/server.crt 
SSLCertificateKeyFile /usr/local/apache2/conf/ssl.key/server.key 
CustomLog /usr/local/apache2/logs/ssl_request_log "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x "%r" %b" 

</VirtualHost> 
```
