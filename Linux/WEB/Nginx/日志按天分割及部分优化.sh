cat > XXX-upstream.conf <<'eof'
upstream fupin {
	check interval=3000 rise=2 fall=5 timeout=1000 type=tcp;
	server 192.168.100.1:10101;
	server 192.168.100.1:10109;
	server 192.168.100.1:10105;
	server 192.168.100.2:10101;
	server 192.168.100.2:10109;
	server 192.168.100.2:10105;
}
eof

cat > ~/nginx/conf/server_general.conf <<'eof'
if ($request_method !~ ^(GET|POST|HEAD|PUT|DELETE)) {
        return 444;
        }
if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
        set $year $1;
        set $month $2;
        set $day $3;
}
location ~ /nginx_status {
        access_log off;
        allow 192.168.0.0/16;
        deny all;
}
eof

ADDRESS=`hostname -i`
cat > XXX.conf <<'eof'
server {
    listen 80;
    server_name ${ADDRESS};
    include server_general.conf;
    location / {
        include proxy_header.conf;
        proxy_pass http://XXX;
        access_log logs/XXX-access-$year-$month-$day.log main;
    }
}
eof

cat > ~/nginx/conf/proxy_header.conf <<'eof'
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $remote_addr;
  proxy_set_header REMOTE_ADD $remote_addr;
  proxy_redirect http:// $scheme://;
eof
