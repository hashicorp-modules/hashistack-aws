output "zREADME" {
  value = <<README
# ------------------------------------------------------------------------------
# ${var.name} HashiStack Consul
# ------------------------------------------------------------------------------

You can now interact with Consul using any of the CLI
(https://www.consul.io/docs/commands/index.html) or
API (https://www.consul.io/api/index.html) commands.

${format("Consul UI: %s %s\n\n%s", module.consul_lb_aws.consul_lb_dns, var.public ? "(Public)" : "(Internal)", var.public ? "The Consul nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!" : "The Consul node(s) are in a private subnet, UI access can only be achieved inside\nthe network through a VPN.")}

Use the CLI to retrieve the Consul members, write a key/value, and read
that key/value.

  $ consul members # Retrieve Consul members
  $ consul kv put cli bar=baz # Write a key/value
  $ consul kv get cli # Read a key/value

Use the HTTP API to retrieve the Consul members, write a key/value,
and read that key/value.

${!var.use_lb_cert ?
"If you're making HTTP API requests to Consul from the Bastion host,
the below env var has been set for you.

  $ export CONSUL_ADDR=http://127.0.0.1:8500

  $ curl \\
      -X GET \\
      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members
  $ curl \\
      -X PUT \\
      -d '{\"bar=baz\"}' \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV
  $ curl \\
      -X GET \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV"
:
"If you're making HTTPS API requests to Consul from the Bastion host,
the below env vars have been set for you.

  $ export CONSUL_ADDR=https://127.0.0.1:8080
  $ export CONSUL_CACERT=/opt/consul/tls/consul-ca.crt
  $ export CONSUL_CLIENT_CERT=/opt/consul/tls/consul.crt
  $ export CONSUL_CLIENT_KEY=/opt/consul/tls/consul.key

  $ curl \\
      -X GET \\
      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\
      $${CONSUL_ADDR}/v1/agent/members | jq '.' # Retrieve Consul members
  $ curl \\
      -X PUT \\
      -d '{\"bar=baz\"}' \\
      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Write a KV
  $ curl \\
      -X GET \\
      -k --cacert $${CONSUL_CACERT} --cert $${CONSUL_CLIENT_CERT} --key $${CONSUL_CLIENT_KEY} \\
      $${CONSUL_ADDR}/v1/kv/api | jq '.' # Read a KV"
}

# ------------------------------------------------------------------------------
# ${var.name} HashiStack Vault Dev Guide Setup
# ------------------------------------------------------------------------------

If you're following the "Dev Guide" with the provided defaults, Vault is
running in -dev mode and using the in-memory storage backend.

The Root token for your Vault -dev instance has been set to "root" and placed in
`/srv/vault/.vault-token`, the `VAULT_TOKEN` environment variable has already
been set by default.

  $ echo $${VAULT_TOKEN} # Vault Token being used to authenticate to Vault
  $ sudo cat /srv/vault/.vault-token # Vault Token has also been placed here

If you're using a storage backend other than in-mem (-dev mode), you will need
to initialize Vault using steps 2 & 3 below.

# ------------------------------------------------------------------------------
# ${var.name} HashiStack Vault Quick Start/Best Practices Guide Setup
# ------------------------------------------------------------------------------

If you're following the "Quick Start Guide" or "Best Practices" guide, you won't
be able to start interacting with Vault from the Bastion host yet as the Vault
server has not been initialized & unsealed. Follow the below steps to set this
up.

1.) SSH into one of the Vault servers registered with Consul, you can use the
below command to accomplish this automatically (we'll use Consul DNS moving
forward once Vault is unsealed).

  $ ssh -A ${lookup(var.users, var.os)}@$(curl http://127.0.0.1:8500/v1/agent/members | jq -M -r \
      '[.[] | select(.Name | contains ("${var.name}-hashistack")) | .Addr][0]')

2.) Initialize Vault

  $ vault operator init

3.) Unseal Vault using the "Unseal Keys" output from the `vault init` command
and check the seal status.

  $ vault operator unseal <UNSEAL_KEY_1>
  $ vault operator unseal <UNSEAL_KEY_2>
  $ vault operator unseal <UNSEAL_KEY_3>
  $ vault status

Repeat steps 1.) and 3.) to unseal the other "standby" Vault servers as well to
achieve high availablity.

4.) Logout of the Vault server (ctrl+d) and check Vault's seal status from the
Bastion host to verify you can interact with the Vault cluster from the Bastion
host Vault CLI.

  $ vault status

# ------------------------------------------------------------------------------
# ${var.name} HashiStack Vault Getting Started Instructions
# ------------------------------------------------------------------------------

You can interact with Vault using any of the
CLI (https://www.vaultproject.io/docs/commands/index.html) or
API (https://www.vaultproject.io/api/index.html) commands.
${__builtin_StringToFloat(replace(replace(var.vault_version, "-ent", ""), ".", "")) >= 0100 || replace(var.vault_version, "-ent", "") != var.vault_version ? format("\nVault UI: %s%s %s\n\n%s", var.use_lb_cert ? "https://" : "http://", module.vault_lb_aws.vault_lb_dns, var.public ? "(Public)" : "(Internal)", var.public ? "The Vault nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!\n" : "The Vault node(s) are in a private subnet, UI access can only be achieved inside\nthe network through a VPN.\n") : ""}
To start interacting with Vault, set your Vault token to authenticate requests.

If using the "Vault Dev Guide", Vault is running in -dev mode & this has been set
to "root" for you. Otherwise we will use the "Initial Root Token" that was output
from the `vault operator init` command.

  $ echo $${VAULT_ADDR} # Address you will be using to interact with Vault
  $ echo $${VAULT_TOKEN} # Vault Token being used to authenticate to Vault
  $ export VAULT_TOKEN=<ROOT_TOKEN> # If Vault token has not been set

Use the CLI to write and read a generic secret.

  $ vault kv put secret/cli foo=bar
  $ vault kv get secret/cli

Use the HTTP API with Consul DNS to write and read a generic secret with
Vault's KV secret engine.

${!var.use_lb_cert ?
"If you're making HTTP API requests to Vault from the Bastion host,
the below env var has been set for you.

  $ export VAULT_ADDR=http://vault.service.vault:8200

  $ curl \\
      -H \"X-Vault-Token: $${VAULT_TOKEN}\" \\
      -X POST \\
      -d '{\"data\": {\"foo\":\"bar\"}}' \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Write a KV secret
  $ curl \\
      -H \"X-Vault-Token: $${VAULT_TOKEN}\" \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Read a KV secret"
:
"If you're making HTTPS API requests to Vault from the Bastion host,
the below env vars have been set for you.

  $ export VAULT_ADDR=https://vault.service.vault:8200
  $ export VAULT_CACERT=/opt/vault/tls/vault-ca.crt
  $ export VAULT_CLIENT_CERT=/opt/vault/tls/vault.crt
  $ export VAULT_CLIENT_KEY=/opt/vault/tls/vault.key

  $ curl \\
      -H \"X-Vault-Token: $VAULT_TOKEN\" \\
      -X POST \\
      -d '{\"data\": {\"foo\":\"bar\"}}' \\
      -k --cacert $${VAULT_CACERT} --cert $${VAULT_CLIENT_CERT} --key $${VAULT_CLIENT_KEY} \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Write a KV secret
  $ curl \\
      -H \"X-Vault-Token: $VAULT_TOKEN\" \\
      -k --cacert $${VAULT_CACERT} --cert $${VAULT_CLIENT_CERT} --key $${VAULT_CLIENT_KEY} \\
      $${VAULT_ADDR}/v1/secret/data/api | jq '.' # Read a KV secret"
}

# ------------------------------------------------------------------------------
# ${var.name} HashiStack Nomad
# ------------------------------------------------------------------------------

You can interact with Nomad using any of the CLI
(https://www.nomadproject.io/docs/commands/index.html) or API
(https://www.nomadproject.io/api/index.html) commands.

${format("Nomad UI: %s%s %s\n\n%s", var.use_lb_cert ? "https://" : "http://", module.nomad_lb_aws.nomad_lb_dns, var.public ? "(Public)" : "(Internal)", var.public ? "The Nomad nodes are in a public subnet with UI & SSH access open from the\ninternet. WARNING - DO NOT DO THIS IN PRODUCTION!" : "The Nomad node(s) are in a private subnet, UI access can only be achieved inside\nthe network through a VPN.")}

Use the CLI to retrieve Nomad servers & clients, then deploy a Redis Docker
container and check it's status.

  $ nomad server members # Check Nomad's server members
  $ nomad node-status # Check Nomad's client nodes
  $ nomad init # Create a skeletion job file to deploy a Redis Docker container

  $ nomad plan example.nomad # Run a nomad plan on the example job
  $ nomad run example.nomad # Run the example job
  $ nomad status # Check that the job is running
  $ nomad status example # Check job details
  $ nomad stop example # Stop the example job
  $ nomad status # Check that the job is stopped

Use the HTTP API to deploy a Redis Docker container.

  $ nomad run -output example.nomad > example.json # Convert job file to JSON

${!var.use_lb_cert ?
"If you're making HTTP API requests to Nomad from the Bastion host,
the below env var has been set for you.

  $ export NOMAD_ADDR=http://nomad.service.consul:4646

  $ curl \\
      -X POST \\
      -d @example.json \\
      $${NOMAD_ADDR}/v1/job/example/plan | jq '.' # Run a nomad plan
  $ curl \\
      -X POST \\
      -d @example.json \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Run the example job
  $ curl \\
      -X GET \\
      $${NOMAD_ADDR}/v1/jobs | jq '.' # Check that the job is running
  $ curl \\
      -X GET \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Check job details
  $ curl \\
      -X DELETE \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Stop the example job
  $ curl \\
      -X GET \\
      $${NOMAD_ADDR}/v1/jobs | jq '.' # Check that the job is stopped"
:
"If you're making HTTPS API requests to Nomad from the Bastion host,
the below env vars have been set for you.

  $ export NOMAD_ADDR=https://nomad.service.consul:4646
  $ export NOMAD_CACERT=/opt/nomad/tls/nomad-ca.crt
  $ export NOMAD_CLIENT_CERT=/opt/nomad/tls/nomad.crt
  $ export NOMAD_CLIENT_KEY=/opt/nomad/tls/nomad.key

  $ curl \\
      -X POST \\
      -d @example.json \\
      -k --cacert $${NOMAD_CACERT} --cert $${NOMAD_CLIENT_CERT} --key $${NOMAD_CLIENT_KEY} \\
      $${NOMAD_ADDR}/v1/job/example/plan | jq '.' # Run a nomad plan on the example job
  $ curl \\
      -X POST \\
      -d @example.json \\
      -k --cacert $${NOMAD_CACERT} --cert $${NOMAD_CLIENT_CERT} --key $${NOMAD_CLIENT_KEY} \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Run the example job
  $ curl \\
      -X GET \\
      -k --cacert $${NOMAD_CACERT} --cert $${NOMAD_CLIENT_CERT} --key $${NOMAD_CLIENT_KEY} \\
      $${NOMAD_ADDR}/v1/jobs | jq '.' # Check that the job is running
  $ curl \\
      -X GET \\
      -k --cacert $${NOMAD_CACERT} --cert $${NOMAD_CLIENT_CERT} --key $${NOMAD_CLIENT_KEY} \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Check job details
  $ curl \\
      -X DELETE \\
      -k --cacert $${NOMAD_CACERT} --cert $${NOMAD_CLIENT_CERT} --key $${NOMAD_CLIENT_KEY} \\
      $${NOMAD_ADDR}/v1/job/example | jq '.' # Stop the example job
  $ curl \\
      -X GET \\
      -k --cacert $${NOMAD_CACERT} --cert $${NOMAD_CLIENT_CERT} --key $${NOMAD_CLIENT_KEY} \\
      $${NOMAD_ADDR}/v1/jobs | jq '.' # Check that the job is stopped"
}
README
}

output "hashistack_asg_id" {
  value = "${element(concat(aws_autoscaling_group.hashistack.*.id, list("")), 0)}" # TODO: Workaround for issue #11210
}

output "consul_sg_id" {
  value = "${module.consul_server_sg.consul_server_sg_id}"
}

output "consul_lb_sg_id" {
  value = "${module.consul_lb_aws.consul_lb_sg_id}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_lb_aws.consul_tg_http_8500_arn}"
}

output "consul_tg_https_8080_arn" {
  value = "${module.consul_lb_aws.consul_tg_https_8080_arn}"
}

output "consul_lb_dns" {
  value = "${module.consul_lb_aws.consul_lb_dns}"
}

output "vault_sg_id" {
  value = "${module.vault_server_sg.vault_server_sg_id}"
}

output "vault_lb_sg_id" {
  value = "${module.vault_lb_aws.vault_lb_sg_id}"
}

output "vault_tg_http_8200_arn" {
  value = "${module.vault_lb_aws.vault_tg_http_8200_arn}"
}

output "vault_tg_https_8200_arn" {
  value = "${module.vault_lb_aws.vault_tg_https_8200_arn}"
}

output "vault_lb_dns" {
  value = "${module.vault_lb_aws.vault_lb_dns}"
}

output "nomad_sg_id" {
  value = "${module.nomad_server_sg.nomad_server_sg_id}"
}

output "nomad_lb_sg_id" {
  value = "${module.nomad_lb_aws.nomad_lb_sg_id}"
}

output "nomad_tg_http_4646_arn" {
  value = "${module.nomad_lb_aws.nomad_tg_http_4646_arn}"
}

output "nomad_tg_https_4646_arn" {
  value = "${module.nomad_lb_aws.nomad_tg_https_4646_arn}"
}

output "nomad_lb_dns" {
  value = "${module.nomad_lb_aws.nomad_lb_dns}"
}

output "hashistack_username" {
  value = "${lookup(var.users, var.os)}"
}
