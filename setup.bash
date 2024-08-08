#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp --directory)"
cd "$TMPDIR"

apt-get --quiet --yes --no-install-recommends update
apt-get --quiet --yes --no-install-recommends upgrade
apt-get --quiet --yes --no-install-recommends install \
  autoconf \
  automake \
  make \
  mysql-server \
  unzip

# tailscale
curl \
  --fail \
  --silent \
  --show-error \
  --location \
  https://tailscale.com/install.sh \
  | sh
cat <<EOF > /etc/sysctl.d/99-tailscale.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --load=/etc/sysctl.d/99-tailscale.conf
# shellcheck disable=SC2154
tailscale up \
  --authkey="${tailscale_auth_key}" \
  --hostname="traccar" \
  --ssh=true

# ddclient
curl \
  --fail \
  --silent \
  --show-error \
  --location \
  --output ddclient.tar.gz \
  https://github.com/ddclient/ddclient/archive/refs/tags/v3.11.2.tar.gz
tar xvfa ddclient.tar.gz
cd ddclient-*
./autogen
./configure \
  --prefix=/usr \
  --sysconfdir=/etc/ddclient \
  --localstatedir=/var
make
make check
make install
cat <<"EOF" > /etc/ddclient/ddclient.conf
pid=/var/run/ddclient.pid
daemon=300
login=token
password=${cloudflare_api_token}
protocol=cloudflare
ssl=true
usev4=webv4
webv4=api.ipify.org
zone=${dns_zone}
${dns_subdomain}.${dns_zone}
EOF
chmod 600 /etc/ddclient/ddclient.conf
cp sample-etc_systemd.service /etc/systemd/system/ddclient.service
systemctl daemon-reload
systemctl enable --now ddclient.service
cd "$TMPDIR"

# traccar
mysql \
  --user=root \
  <<"EOF"
ALTER USER 'root'@'localhost'
  IDENTIFIED WITH mysql_native_password BY '${mysql_password}';
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
CREATE DATABASE traccar;
EOF
curl \
  --fail \
  --silent \
  --show-error \
  --location \
  --output traccar.zip \
  https://www.traccar.org/download/traccar-linux-64-latest.zip
unzip traccar.zip
./traccar.run
cat <<"EOF" > /opt/traccar/conf/traccar.xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE properties SYSTEM 'http://java.sun.com/dtd/properties.dtd'>
<properties>
  <entry key='config.default'>./conf/default.xml</entry>
  <entry key='web.address'>127.0.0.1</entry>
  <entry key='database.driver'>com.mysql.jdbc.Driver</entry>
  <entry key='database.url'>jdbc:mysql://localhost/traccar?zeroDateTimeBehavior=round&amp;serverTimezone=UTC&amp;allowPublicKeyRetrieval=true&amp;useSSL=false&amp;allowMultiQueries=true&amp;autoReconnect=true&amp;useUnicode=yes&amp;characterEncoding=UTF-8&amp;sessionVariables=sql_mode=''</entry>
  <entry key='database.user'>root</entry>
  <entry key='database.password'>${mysql_password}</entry>
</properties>
EOF
systemctl enable --now traccar.service
tailscale serve --bg 8082
