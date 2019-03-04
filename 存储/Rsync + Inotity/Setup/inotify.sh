#!/bin/bash

tar zxvf inotify-tools-3.13.tar.gz
cd inotify-tools-3.13
./configure --prefix=/usr/local
make && make install
cd -
