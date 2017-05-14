#!/bin/bash

CONSUL_USER=$${USER:-"consul"}
CONSUL_GROUP=$${GROUP:-"consul"}
CONFIG_DIR="/etc/consul.d"
DATA_DIR="/opt/consul/data"
#Removing trailing whitespace in hostname -I
IP_ADDR="$(hostname -I| sed 's/[ \t]*$//')"

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="hashistack-$${instance_id}"

# set the hostname (before starting consul)
hostnamectl set-hostname "$${new_hostname}"

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"consul_retry_join_ec2\", \"tag_value\": \"${consul_retry_join_ec2}\"}" < /etc/consul.d/consul-default.json > /tmp/consul-default.tmp

# add the cluster instance count to the config with jq
jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json > /tmp/consul-server.tmp

# cp rather than mv to maintain owner and permissions on files
cp /tmp/consul-default.tmp /etc/consul.d/consul-default.json
cp /tmp/consul-server.tmp /etc/consul.d/consul-server.json

sudo chown -R $${CONSUL_USER}:$${CONSUL_GROUP} $${CONFIG_DIR} $${DATA_DIR}

systemctl enable consul
systemctl start consul

# Use consul to assemble nomad cluster

cat <<EOF > /etc/nomad.d/nomad-consul.hcl
consul {
  address = "127.0.0.1:8500"
  auto_advertise = true

  server_auto_join = true
  client_auto_join = true
}
EOF

# Set an appropiate bootstrap_expect for Nomad
sed -i 's/  bootstrap_expect = 1/  bootstrap_expect = ${cluster_size}/g' /etc/nomad.d/nomad-server.hcl

# Fix Nomad Advertise Addresses
cat <<EOF > /etc/nomad.d/nomad-advertise.hcl
advertise {
  http = "$${IP_ADDR}"
  serf = "$${IP_ADDR}"
  rpc = "$${IP_ADDR}"

}
EOF

systemctl enable nomad
service nomad start

# Configure Vault to use Consul as Storage Backend
cat <<EOF > /etc/vault.d/vault-consul.hcl
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}
EOF

systemctl enable vault
service vault start
