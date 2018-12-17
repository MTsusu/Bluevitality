#!/bin/sh

cat<<EOF
Status: 200 OK
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=random-$(uuidgen -r).bin
Cache-Control: no-cache
Content-Length: 134217728

EOF
dd if=/dev/urandom bs=4M count=32
