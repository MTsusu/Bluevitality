#### Server
```python
#!/usr/bin/env python

import socket
import sys
from thread import *
 
HOST = ''   
PORT = 8888 
 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Socket created'
 
try:
    s.bind((HOST, PORT))
except socket.error , msg:
    print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
    sys.exit()
     
print 'Socket bind complete'

s.listen(10)
print 'Socket now listening'
 
def clientthread(conn):
    conn.send('Welcome to the server. Type something and hit enter\n') #send only takes string
   
    while True:
        data = conn.recv(1024)
        print data
        reply = 'OK...' + data
        if not data: 
            break
        conn.sendall(reply)
    conn.close()
 
#now keep talking with the client
while True:
    conn, addr = s.accept()
    print 'Connected with ' + addr[0] + ':' + str(addr[1])
    start_new_thread(clientthread ,(conn,))
    
s.close()
```

#### Clent
```bash
[root@localhost ~]# telnet localhost 8889
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Welcome to the server. Type something and hit enter
1
OK...1
2
OK...2
3
OK...3
```
