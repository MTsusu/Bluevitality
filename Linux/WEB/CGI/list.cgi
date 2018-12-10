#!/bin/bash

export LANG=en_US.UTF-8
echo 'Status: 200 OK'
echo 'Content-Type: text/plain; charset: utf-8'
echo
if [ "$QUERY_STRING" ]
then
    # Not garanteed to be safe
    ls -l "$QUERY_STRING" 2>&1
else
    ls -l 2>&1
fi
echo
