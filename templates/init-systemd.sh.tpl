#!/bin/bash

echo "[---Begin init-systemd.sh---]"
HOSTNAME=${name}-hashistack-$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

if [[ ! -z $(which yum 2>/dev/null) ]]; then
  hostnamectl set-hostname "$HOSTNAME"
elif [[ ! -z $(which apt-get 2>/dev/null) ]]; then
  sudo hostname $HOSTNAME
  sudo sed -i "2i127.0.1.1 $HOSTNAME" /etc/hosts
  echo $HOSTNAME | sudo tee /etc/hostname
else
  echo "OS detection failure"
fi

echo "[---init-systemd.sh complete---]"
${user_data}
