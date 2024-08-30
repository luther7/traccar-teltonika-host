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
CAfile = ${CERT:-/certificates/cert.pem}
cert = ${CERT:-/certificates/cert.pem}
key = ${CERT:-/certificates/key.pem}
accept = 5053
connect = ${CONNECT}
sslVersion = TLSv1.2
options = NO_SSLv2
options = NO_SSLv3
EOF
exec "$@"
