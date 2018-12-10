#!/bin/bash

echo 'Status: 200 OK'
echo 'Content-Type: text/html; charset=utf-8'
echo 'Cache-Control: no-cache'
echo 'Pragma: no-cache'
echo
#[[ "$REMOTE_ADDR" =~ ':' ]] &&
REMOTE_ADDR="[$REMOTE_ADDR]"
echo "<html><head><title>$REMOTE_ADDR:$REMOTE_PORT</title></head><body><h1>IP: $REMOTE_ADDR:$REMOTE_PORT</h1><h1>User Agent: </h1><pre style=\"font-size: large\">$HTTP_USER_AGENT</pre><div>Page generated on $(date -R)</body></html>"
