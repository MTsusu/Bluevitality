
#### Varnish List
```bash
[root@localhost ~]# rpm -ql varnish
/etc/logrotate.d/varnish                    #日志轮转脚本
/etc/varnish
/etc/varnish/default.vcl                    #VCL
/etc/varnish/varnish.params                 #配置参数
/run/varnish.pid                            #
/usr/bin/varnishadm                         #相关的命令
/usr/bin/varnishhist                        #
/usr/bin/varnishlog                         #
/usr/bin/varnishncsa                        #
/usr/bin/varnishstat                        #
/usr/bin/varnishtest                        #
/usr/bin/varnishtop                         #
/usr/lib/systemd/system/varnish.service             #systemd配置文件
/usr/lib/systemd/system/varnishlog.service          #日志相关
/usr/lib/systemd/system/varnishncsa.service         #
/usr/sbin/varnish_reload_vcl                        #重载配置时使用
/usr/sbin/varnishd                                  #主程序
/usr/share/doc/varnish-4.0.5
/usr/share/doc/varnish-4.0.5/LICENSE
/usr/share/doc/varnish-4.0.5/README
/usr/share/doc/varnish-4.0.5/builtin.vcl
/usr/share/doc/varnish-4.0.5/changes.rst
/usr/share/doc/varnish-4.0.5/example.vcl
/usr/share/man/man1/varnishadm.1.gz
/usr/share/man/man1/varnishd.1.gz
/usr/share/man/man1/varnishhist.1.gz
/usr/share/man/man1/varnishlog.1.gz
/usr/share/man/man1/varnishncsa.1.gz
/usr/share/man/man1/varnishstat.1.gz
/usr/share/man/man1/varnishtest.1.gz
/usr/share/man/man1/varnishtop.1.gz
/usr/share/man/man3/vmod_directors.3.gz
/usr/share/man/man3/vmod_std.3.gz
/usr/share/man/man7/varnish-cli.7.gz
/usr/share/man/man7/varnish-counters.7.gz
/usr/share/man/man7/vcl.7.gz
/usr/share/man/man7/vsl-query.7.gz
/usr/share/man/man7/vsl.7.gz
/var/lib/varnish
/var/log/varnish
```
#### varnish.service
```
[root@localhost ~]# systemctl cat varnish
# /usr/lib/systemd/system/varnish.service
[Unit]
Description=Varnish Cache, a high-performance HTTP accelerator
After=network.target

[Service]
# Maximum number of open files (for ulimit -n)
LimitNOFILE=131072

# Locked shared memory (for ulimit -l)
# Default log size is 82MB + header
LimitMEMLOCK=82000

# Maximum size of the corefile.
LimitCORE=infinity

EnvironmentFile=/etc/varnish/varnish.params         #载入Key=Value配置变量在下面的ExecStart中调用

Type=forking
PIDFile=/var/run/varnish.pid
PrivateTmp=true
ExecStart=/usr/sbin/varnishd \
        -P /var/run/varnish.pid \
        -f $VARNISH_VCL_CONF \
        -a ${VARNISH_LISTEN_ADDRESS}:${VARNISH_LISTEN_PORT} \
        -T ${VARNISH_ADMIN_LISTEN_ADDRESS}:${VARNISH_ADMIN_LISTEN_PORT} \
        -S $VARNISH_SECRET_FILE \
        -u $VARNISH_USER -g $VARNISH_GROUP \
        -s $VARNISH_STORAGE \
        $DAEMON_OPTS

ExecReload=/usr/sbin/varnish_reload_vcl

[Install]
WantedBy=multi-user.target

[root@localhost ~]# cat /etc/varnish/varnish.params
RELOAD_VCL=1
VARNISH_VCL_CONF=/etc/varnish/default.vcl
VARNISH_LISTEN_PORT=6081
VARNISH_ADMIN_LISTEN_ADDRESS=127.0.0.1
VARNISH_ADMIN_LISTEN_PORT=6082
VARNISH_SECRET_FILE=/etc/varnish/secret
VARNISH_STORAGE="malloc,256M"
VARNISH_USER=varnish
VARNISH_GROUP=varnish
```
