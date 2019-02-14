```bash
#以服务模式运行，使用UDP监听在192.168.0.6的9999端口
[root@Server ~]# iperf -s -u --bind 192.168.0.6 --port 9999     
------------------------------------------------------------
Server listening on UDP port 9999
Binding to local address 192.168.0.6
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)

#使用UDP连接192.168.0.6的9999端口，带宽100M并持续60s
[root@Client ~]# iperf -u -c 192.168.0.6 --port 9999 -b 100M -t 60 
------------------------------------------------------------
Client connecting to 192.168.0.6, UDP port 9999
Sending 1470 byte datagrams, IPG target: 112.15 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.7 port 35205 connected with 192.168.0.6 port 9999
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-60.0 sec   750 MBytes   105 Mbits/sec
[  3] Sent 534985 datagrams
[  3] Server Report:
[  3]  0.0-60.0 sec   750 MBytes   105 Mbits/sec   0.000 ms   24/534985 (0%)

#使用UDP连接192.168.0.6的9999端口，发起10个线程，每个线程带宽5M，持续10s
[root@Client ~]# iperf -u -c 192.168.0.6 --port 9999 -b 5M --parallel 10 -t 10  
------------------------------------------------------------
Client connecting to 192.168.0.6, UDP port 9999
Sending 1470 byte datagrams, IPG target: 2243.04 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[ 12] local 192.168.0.7 port 60285 connected with 192.168.0.6 port 9999
[  3] local 192.168.0.7 port 50608 connected with 192.168.0.6 port 9999
[  5] local 192.168.0.7 port 33917 connected with 192.168.0.6 port 9999
[  4] local 192.168.0.7 port 46224 connected with 192.168.0.6 port 9999
[  7] local 192.168.0.7 port 59975 connected with 192.168.0.6 port 9999
[  8] local 192.168.0.7 port 39126 connected with 192.168.0.6 port 9999
[  9] local 192.168.0.7 port 35620 connected with 192.168.0.6 port 9999
[  6] local 192.168.0.7 port 51444 connected with 192.168.0.6 port 9999
[ 10] local 192.168.0.7 port 52785 connected with 192.168.0.6 port 9999
[ 11] local 192.168.0.7 port 42913 connected with 192.168.0.6 port 9999
[ ID] Interval       Transfer     Bandwidth
[ 12]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec
[ 12] Sent 4459 datagrams
[  3]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec
[  3] Sent 4458 datagrams
[  5]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec
[  5] Sent 4458 datagrams
[  4]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec
[  4] Sent 4458 datagrams
[  7]  0.0-10.0 sec  2.87 KBytes  2.35 Kbits/sec
[  7] Sent 2 datagrams
[  8]  0.0-10.0 sec  1.44 KBytes  1.18 Kbits/sec
[  8] Sent 1 datagrams
[  9]  0.0-10.0 sec  1.44 KBytes  1.18 Kbits/sec
[  9] Sent 1 datagrams
[  6]  0.0-10.0 sec  1.44 KBytes  1.17 Kbits/sec
[  6] Sent 1 datagrams
[ 11]  0.0-10.0 sec  1.44 KBytes  1.17 Kbits/sec
[ 11] Sent 1 datagrams
[ 10]  0.0-10.0 sec  1.44 KBytes  1.17 Kbits/sec
[ 10] Sent 1 datagrams
[SUM]  0.0-10.0 sec  25.0 MBytes  21.0 Mbits/sec
[SUM] Sent 17840 datagrams
[  4] Server Report:
[  4]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec   0.000 ms    1/ 4458 (0%)
[  8] Server Report:
[  8]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec   0.000 ms    4/ 4459 (0%)
[  5] Server Report:
[  5]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec   0.000 ms    0/ 4458 (0%)
[  3] Server Report:
[  3]  0.0-10.0 sec  6.26 MBytes  5.25 Mbits/sec   0.000 ms    0/ 4458 (0%)
[  3] 0.00-10.00 sec  4 datagrams received out-of-order
[  6] Server Report:
[  6]  0.0-10.0 sec  6.24 MBytes  5.23 Mbits/sec   0.000 ms    7/ 4459 (0%)
[  9] Server Report:
[  9]  0.0-10.0 sec  6.25 MBytes  5.23 Mbits/sec   0.000 ms    4/ 4459 (0%)
[ 12] Server Report:
[ 12]  0.0-10.0 sec  6.25 MBytes  5.24 Mbits/sec   0.000 ms    0/ 4459 (0%)
[ 12] 0.00-10.01 sec  2 datagrams received out-of-order
[  7] Server Report:
[  7]  0.0-10.0 sec  6.24 MBytes  5.23 Mbits/sec   0.000 ms    6/ 4459 (0%)
[ 11] Server Report:
[ 11]  0.0-10.0 sec  6.25 MBytes  5.23 Mbits/sec   0.000 ms    1/ 4459 (0%)
[ 11] 0.00-10.02 sec  1 datagrams received out-of-order
[ 10] Server Report:
[ 10]  0.0-10.0 sec  6.26 MBytes  5.24 Mbits/sec   0.000 ms    0/ 4459 (0%)
[ 10] 0.00-10.02 sec  9 datagrams received out-of-order

#以100M为数据发送速率，进行上下行带宽测试
[root@Client ~]# iperf -u -c 192.168.1.1 -b 100M -d -t 60        
```
#### TCP mode
```bash
[root@Server ~]# iperf -s                           #服务器端
[root@Client ~]# iperf -c 192.168.0.6 -t 60         #在tcp模式下C端到S端192.168.0.6上传带宽测试，持续60s
[root@Client ~]# iperf -c 192.168.0.6 -P 30 -t 60   #C端同时向S端发起30个连接线程
[root@Client ~]# iperf -c 192.168.0.6 -d -t 60      #进行上下行带宽测试
```
#### iperf --help
```txt
[root@Client ~]# iperf -h
Usage: iperf [-s|-c host] [options]
       iperf [-h|--help] [-v|--version]

Client/Server:
  -b, --bandwidth #[kmgKMG | pps]  bandwidth to send at in bits/sec or packets per second
  -e, --enhancedreports    use enhanced reporting giving more tcp/udp and traffic information
  -f, --format    [kmgKMG]   format to report: Kbits, Mbits, KBytes, MBytes
  -i, --interval  #        seconds between periodic bandwidth reports
  -l, --len       #[kmKM]    length of buffer in bytes to read or write (Defaults: TCP=128K, v4 UDP=1470, v6 UDP=1450)
  -m, --print_mss          print TCP maximum segment size (MTU - TCP/IP header)
  -o, --output    <filename> output the report or error message to this specified file
  -p, --port      #        server port to listen on/connect to
  -u, --udp                use UDP rather than TCP
      --udp-counters-64bit use 64 bit sequence numbers with UDP
  -w, --window    #[KM]    TCP window size (socket buffer size)
  -z, --realtime           request realtime scheduler
  -B, --bind      <host>   bind to <host>, an interface or multicast address
  -C, --compatibility      for use with older versions does not sent extra msgs
  -M, --mss       #        set TCP maximum segment size (MTU - 40 bytes)
  -N, --nodelay            set TCP no delay, disabling Nagle's Algorithm
  -S, --tos       #        set the socket's IP_TOS (byte) field

Server specific:
  -s, --server             run in server mode
  -t, --time      #        time in seconds to listen for new connections as well as to receive traffic (default not set)
  -U, --single_udp         run in single threaded UDP mode
  -D, --daemon             run the server as a daemon
  -V, --ipv6_domain        Enable IPv6 reception by setting the domain and socket to AF_INET6 (Can receive on both IPv4 and IPv6)

Client specific:
  -c, --client    <host>   run in client mode, connecting to <host>
  -d, --dualtest           Do a bidirectional test simultaneously
  -n, --num       #[kmgKMG]    number of bytes to transmit (instead of -t)
  -r, --tradeoff           Do a bidirectional test individually
  -t, --time      #        time in seconds to transmit for (default 10 secs)
  -B, --bind [<ip> | <ip:port>] bind src addr(s) from which to originate traffic
  -F, --fileinput <name>   input the data to be transmitted from a file
  -I, --stdin              input the data to be transmitted from stdin
  -L, --listenport #       port to receive bidirectional tests back on
  -P, --parallel  #        number of parallel client threads to run
  -R, --reverse            reverse the test (client receives, server sends)
  -T, --ttl       #        time-to-live, for multicast (default 1)
  -V, --ipv6_domain        Set the domain to IPv6 (send packets over IPv6)
  -X, --peer-detect        perform server version detection and version exchange
  -Z, --linux-congestion <algo>  set TCP congestion control algorithm (Linux only)

Miscellaneous:
  -x, --reportexclude [CDMSV]   exclude C(connection) D(data) M(multicast) S(settings) V(server) reports
  -y, --reportstyle C      report as a Comma-Separated Values
  -h, --help               print this message and quit
  -v, --version            print version information and quit

[kmgKMG] Indicates options that support a k,m,g,K,M or G suffix
Lowercase format characters are 10^3 based and uppercase are 2^n based
(e.g. 1k = 1000, 1K = 1024, 1m = 1,000,000 and 1M = 1,048,576)

The TCP window size option can be set by the environment variable
TCP_WINDOW_SIZE. Most other options can be set by an environment variable
IPERF_<long option name>, such as IPERF_BANDWIDTH.

Source at <http://sourceforge.net/projects/iperf2/>
Report bugs to <iperf-users@lists.sourceforge.net>
```