#!/bin/sh
set -e

cat << EOF > /etc/stunnel.conf
client = no
verify = 2
setuid = nobody
setgid = nobody
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
syslog = no
foreground = yes
[traccar]
CAfile = ${CERT:-/certificates/ca-cert.pem}
cert = ${CERT:-/certificates/ca-cert.pem}
key = ${CERT:-/certificates/ca-private-key.pem.key}
accept = 5200
connect = ${CONNECT}
sslVersion = TLSv1.2
options = NO_SSLv2
options = NO_SSLv3
EOF
exec "$@"
