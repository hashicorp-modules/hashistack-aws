# hashistack-aws
Provides the resources for an Autoscaling group in AWS running Consul, Vault and Nomad.

## Requirements

This module requires a pre-existing AWS key pair, VPC and subnet be available to
deploy the auto-scaling group within. It's recommended you combine this module
with [network-aws](https://github.com/hashicorp-modules/network-aws/) which
provisions a VPC and a private and public subnet per AZ. See the usage section
for further guidance.

The [images-aws](https://github.com/hashicorp-modules/images-aws) module is used
 to leverage existing Packer Images

### Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Terraform Variables

You can pass the following Terraform variables during `terraform apply` or
in a `terraform.tfvars` file. Examples below:

- cluster_name = "ProductionCluster"
- os = "RHEL"
- os_version = "7.3"
- ssh_key_name = "my-ssh-key"
- subnet_ids = ["subnet-0ab1cd2e"]
- vpc_id = "vpc-123abc45"
- consul_version = "0.8.3"
- nomad_version  = "0.5.6"
- vault_version  = "0.7.2"

An existing `terraform.tfvars.example` file exists to be leveraged as an example.
## Outputs

- `asg_id`
- `consul_client_sg_id`
- `server_sg_id`

## Images

- [hashistack.json Packer template](https://github.com/hashicorp-modules/packer-templates/blob/master/hashistack/hashistack.json)

## Usage

When combined with [network-aws](https://github.com/hashicorp-modules/network-aws/)
the `vpc_id` and `subnet_ids` variables are output from that module so you should
not supply them. Replace the `cluster_name` variable with `environment_name`.

```hcl
variable "environment_name" {
  default = "consul-test"
  description = "Environment Name"
}

variable "os" {
  # case sensitive for AMI lookup
  default = "RHEL"
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  default = "7.3"
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

variable "consul_version" {
  default     = "0.8.3"
  description = "Consul Agent version to use ie 0.8.1"
}

variable "nomad_version" {
  default     = "0.5.6"
  description = "Nomad version to use ie 0.5.6"
}

variable "vault_version" {
  default     = "0.7.2"
  description = "Vault version to use ie 0.7.1"
}

variable "ssh_key_name" {
  default = "test_aws"
  description = "Pre-existing AWS key name you will use to access the instance(s)"
}

module "network-aws" {
  source           = "git@github.com:hashicorp-modules/network-aws.git"
  environment_name = "${var.environment_name}"
  os               = "${var.os}"
  os_version       = "${var.os_version}"
  ssh_key_name     = "${var.ssh_key_name}"
}

module "hashistack-aws" {
  source         = "git@github.com:hashicorp-modules/hashistack-aws.git"
  cluster_name   = "${var.environment_name}-hashistack-asg"
  os             = "${var.os}"
  os_version     = "${var.os_version}"
  consul_version = "${var.consul_version}"
  nomad_version  = "${var.nomad_version}"
  vault_version  = "${var.vault_version}"
  ssh_key_name   = "${var.ssh_key_name}"
  subnet_ids     = "${module.network-aws.subnet_private_ids}"
  vpc_id         = "${module.network-aws.vpc_id}"
}
```
### Limitations
- Vault is not configured to use TLS, please provide a set of certificates. It is strongly discouraged to use Vault without TLS.
- Vault is not initialized as the key shards need to be distributed to key holders, and it is suggested to encrypt them with GPG. Please refer to the [Vault documentation](https://www.vaultproject.io/docs/internals/architecture.html).
- Nomad is not configured to use Vault as it requires a Vault Token. Please refer to the [Nomad documentation](https://www.nomadproject.io/docs/vault-integration/) for information on how to configure the integration.
