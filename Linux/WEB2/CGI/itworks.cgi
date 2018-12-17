#!/bin/bash

echo 'Status: 200 OK'
echo 'Content-Type: text/html; charset=utf-8'
echo 'Cache-Control: no-cache'
echo 'Pragma: no-cache'
echo
echo '<html>'
echo '<head>'
echo '<title>It works!</title>'
echo '</head>'
echo '<body>'
echo '<h1>It works!</h1>'
echo '<hr />'
echo "<h2>Your IP address is: <tt>$REMOTE_ADDR</tt></h2>"
echo '<ul style="font-size: medium">'
if [[ "$REMOTE_ADDR" =~ ':' ]]
then
    echo '<li style="color: darkgreen">You are using IPv6.</li>'
else
    echo '<li style="color: red">You are using IPv4.</li>'
fi
if [ "$SERVER_PORT" == 443 ]
then
    echo '<li style="color: darkgreen">You are using HTTPS.</li>'
else
    echo '<li style="color: red">You are not using HTTPS.</li>'
fi
echo '</ul>'
echo '<h2>Your User-Agent is:</h2>'
echo "<blockquote><pre style=\"font-size: large\">$HTTP_USER_AGENT</pre></blockquote>"
echo '</body>'
echo '</html>'
echo
