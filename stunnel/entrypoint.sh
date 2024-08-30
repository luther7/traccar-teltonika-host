#!/bin/sh
set -e

cat << EOF > /etc/stunnel.conf
verify = 2
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
syslog = no
delay = yes
foreground = yes
[certificate-based server]
accept = 5052
connect = ${CONNECT}
cert = ${CERT:-/cert/cert.pem}"
key = ${KEY:-/cert/key.pem}"
EOF
exec /usr/bin/stunnel /etc/stunnel.conf
