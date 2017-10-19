#!/bin/bash -ex

# What follows is a stop-gap to get the libreswan rpm installed
# The EPEL repo removed lib-unbound, which is required by libreswan
# This resolves that by using the libreswan repo itself

# setup the libreswan repository
cat > /etc/yum.repos.d/libreswan.repo <<EOF
[libreswan]
name=LibreSwan
baseurl=https://download.libreswan.org/binaries/rhel/6/x86_64/
enabled=1
failovermethod=priority
metadata_expire=1d
skip_if_unavailable=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-libreswan
EOF

# install the software
yum install -y libreswan-3.17 ppp xl2tpd 2>&1

# This is the end of the stop-gap, what follows is the original script

# Now that we have MONyog we should leave Postfix running so that
# notifications work.
#
#/sbin/service postfix stop
#/sbin/chkconfig postfix off

# There seems to be a bug that causes these to hiccup, there is no real harm in just
# leaving it running.
#
#/sbin/service codedeploy-agent stop
#/sbin/chkconfig codedeploy-agent off

# Set some local variables
PRIVATE_IP=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
PUBLIC_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
VPN_DNSHOST=`grep -o "nameserver.*" /etc/resolv.conf | awk '{print $2}'`

# Setup IPSEC Tunnel
cat > /etc/ipsec.conf <<EOF
config setup
  protostack=netkey
  dumpdir=/var/run/pluto/
  nat_traversal=yes
  virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:100.64.0.0/10,%v6:fd00::/8,%v6:fe80::/10,%4:!192.168.100.0/24

include /etc/ipsec.d/*.conf
EOF

cat > /etc/ipsec.d/vpnpsk.conf <<EOF
conn vpnpsk
  connaddrfamily=ipv4
  auto=add
  left=$PRIVATE_IP
  leftid=$PUBLIC_IP
  leftsubnet=$PRIVATE_IP/32
  leftnexthop=%defaultroute
  leftprotoport=17/1701
  rightprotoport=17/%any
  right=%any
  rightsubnetwithin=0.0.0.0/0
  forceencaps=yes
  authby=secret
  pfs=no
  type=transport
  auth=esp
  ike=3des-sha1,aes-sha1
  phase2alg=3des-sha1,aes-sha1
  rekey=no
  keyingtries=5
  dpddelay=30
  dpdtimeout=120
  dpdaction=clear
EOF

# Set pre-shared key
cat > /etc/ipsec.d/vpnpsk.secrets <<EOF
$PUBLIC_IP  %any  : PSK "testing"
EOF

chmod 600 /etc/ipsec.d/vpnpsk.secrets

# Setup XL2TP
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

[lns default]
ip range = 192.168.100.2-192.168.100.10
local ip = 192.168.100.1
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

cat > /etc/ppp/options.xl2tpd <<EOF
ipcp-accept-local
ipcp-accept-remote
ms-dns $VPN_DNSHOST
noccp
auth
crtscts
idle 1800
mtu 1375
mru 1375
nodefaultroute
debug
lock
proxyarp
connect-delay 5000
logfile /var/log/ppp.log
EOF

# Setup PPP user accounts
#cat $RS_ATTACH_DIR/vpn_users > /etc/ppp/chap-secrets
echo neilgreggs * testing * > /etc/ppp/chap-secrets

chmod 600 /etc/ppp/chap-secrets

# Tweak kernel settings
cat > /etc/sysctl.conf <<EOF
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.printk = 8 4 1 7
kernel.printk_ratelimit_burst = 10
kernel.printk_ratelimit = 5
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
kernel.randomize_va_space = 1
net.core.wmem_max=12582912
net.core.rmem_max=12582912
net.ipv4.tcp_rmem= 10240 87380 12582912
net.ipv4.tcp_wmem= 10240 87380 12582912
EOF

# Setup iptables
cat > /etc/sysconfig/iptables <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:ICMPALL - [0:0]
:ZREJ - [0:0]
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp --icmp-type 255 -j ICMPALL
-A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -p udp -m multiport --dports 500,4500 -j ACCEPT
-A INPUT -p udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
-A INPUT -p udp --dport 1701 -j DROP
-A INPUT -j ZREJ
-A FORWARD -i eth+ -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i ppp+ -o eth+ -j ACCEPT
-A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS  --clamp-mss-to-pmtu
-A FORWARD -j ZREJ
-A ICMPALL -p icmp --fragment -j DROP
-A ICMPALL -p icmp --icmp-type 0 -j ACCEPT
-A ICMPALL -p icmp --icmp-type 3 -j ACCEPT
-A ICMPALL -p icmp --icmp-type 4 -j ACCEPT
-A ICMPALL -p icmp --icmp-type 8 -j ACCEPT
-A ICMPALL -p icmp --icmp-type 11 -j ACCEPT
-A ICMPALL -p icmp -j DROP
-A ZREJ -p tcp -j REJECT --reject-with tcp-reset
-A ZREJ -p udp -j REJECT --reject-with icmp-port-unreachable
-A ZREJ -j REJECT --reject-with icmp-proto-unreachable
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 192.168.100.0/24 -o eth+ -j SNAT --to-source $PRIVATE_IP
COMMIT
EOF

# rc.local
cat > /etc/rc.local <<EOF
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

/sbin/service ipsec restart
/sbin/service xl2tpd restart
echo 1 > /proc/sys/net/ipv4/ip_forward
exit 0
EOF

# Fire everything up

# Make kernel settings take effect
sysctl -p

# Make iptables rules take effect
service iptables restart

# Turn services on
chkconfig xl2tpd on
chkconfig ipsec on
service ipsec start
service xl2tpd start

exit
