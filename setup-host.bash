#!/usr/bin/env bash
set -euo pipefail

echo "-- Beginning Traccar host setup script"

echo "--> Update and upgrade packages"
apt-get --quiet --yes --no-install-recommends update
apt-get --quiet --yes --no-install-recommends upgrade

echo "--> Install, configure and start tailscale"
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

echo "--> Mount storage volume"

if ! file --special-files --dereference /dev/nvme1n1 \
  | grep --silent ext4; then
  mkfs.ext4 /dev/nvme1n1
fi
mkdir /storage
storage_uuid=$( \
  lsblk --output name,UUID \
  | grep nvme1n1 \
  | awk '{ print $2 }'
)
echo "UUID=$storage_uuid  /storage  ext4  defaults,nofail  0  2" >> /etc/fstab
systemctl daemon-reload
mount /dev/nvme1n1 /storage
mount --all
chown ubuntu:ubuntu --recursive /storage

echo "--> Install and configure podman"
mkdir --parents /home/ubuntu/.config/containers/
cat <<EOF > /home/ubuntu/.config/containers/storage.conf
[storage]
driver = "overlay"
runroot = "/run/user/1000/containers"
graphroot = "/storage"
EOF
chown ubuntu:ubuntu --recursive /home/ubuntu/.config
apt-get --quiet --yes --no-install-recommends install \
  catatonit \
  podman \
  slirp4netns \
  uidmap
loginctl enable-linger ubuntu
systemctl --machine=ubuntu@ --user --now enable podman.socket

echo "-- Completed Traccar host setup script"
