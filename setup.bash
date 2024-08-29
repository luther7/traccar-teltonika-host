#!/usr/bin/env bash
set -euo pipefail

apt-get --quiet --yes --no-install-recommends update
apt-get --quiet --yes --no-install-recommends upgrade
apt-get --quiet --yes --no-install-recommends install \
  catatonit \
  podman \
  slirp4netns \
  uidmap
loginctl enable-linger ubuntu
systemctl --machine=ubuntu@ --user --now enable podman.socket
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
  --authkey="${tailscale_authkey}" \
  --hostname="traccar-host" \
  --ssh=true
