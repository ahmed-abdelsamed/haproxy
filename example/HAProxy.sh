$ yum install haproxy
$ cat > /etc/haproxy/haproxy.cfg << EOF
# Global settings
#---------------------------------------------------------------------
global
    maxconn     20000
    log         /dev/log local0 info
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    user        haproxy
    group       haproxy
    daemon
# turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          300s
    timeout server          300s
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 20000

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /

frontend  openshift-app-https
    bind *:443
    default_backend openshift-app-https
    mode tcp
    option tcplog

backend openshift-app-https
    balance roundrobin
    mode tcp
    server      worker-01 192.168.1.9:443 check
    server      worker-02 192.168.1.10:443 check
    server      worker-03 192.168.1.11:443 check

frontend  openshift-app-http
    bind *:80
    default_backend openshift-app-http
    mode tcp
    option tcplog
backend openshift-app-http
    balance roundrobin
    mode tcp
    server      worker-01 192.168.1.9:80 check
    server      worker-02 192.168.1.10:80 check
    server      worker-03 192.168.1.11:80 check

frontend  master-api
    bind *:6443
    default_backend master-api-be
    mode tcp
    option tcplog

backend master-api-be
    balance roundrobin
    mode tcp
    server      bootstrap 192.168.1.5:6443 check
    server      master-01 192.168.1.6:6443 check
    server      master-02 192.168.1.7:6443 check
    server      master-03 192.168.1.8:6443 check

frontend  master-api-2
    bind *:22623
    default_backend master-api-2-be
    mode tcp
    option tcplog

backend master-api-2-be
    balance roundrobin
    mode tcp
    server      bootstrap 192.168.1.5:22623 check
    server      master-01 192.168.1.6:22623 check
    server      master-02 192.168.1.7:22623 check
    server      master-03 192.168.1.8:22623 check
EOF
