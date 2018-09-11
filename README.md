# AWS HashiStack Terraform Module

Provisions resources for a HashiStack auto-scaling group in AWS.

- A HashiStack cluster with one node in each private subnet

## Requirements

This module requires a pre-existing AWS key pair, VPC and subnet be available to deploy the auto-scaling group within. It's recommended you combine this module with [network-aws](https://github.com/hashicorp-modules/network-aws/) which provisions a VPC and a private and public subnet per AZ. See the usage section for further guidance.

Checkout [examples](./examples) for fully functioning examples.

### Environment Variables

- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Input Variables

- `create`: [Optional] Create Module, defaults to true.
- `name`: [Optional] Name for resources, defaults to "hashistack-aws".
- `release_version`: [Optional] Release version tag to use (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1), defaults to "0.1.0", view releases at https://github.com/hashicorp/guides-configuration#hashistack-version-tables.
- `consul_version`: [Optional] Consul version tag to use (e.g. 1.2.0 or 1.2.0-ent), defaults to "1.2.0".
- `vault_version`: [Optional] Vault version tag to use (e.g. 0.10.3 or 0.10.3-ent), defaults to "0.10.3".
- `nomad_version`: [Optional] Nomad version tag to use (e.g. 0.8.4 or 0.8.4-ent), defaults to "0.8.4".
- `os`: [Optional] Operating System to use (e.g. RHEL or Ubuntu), defaults to "RHEL".
- `os_version`: [Optional] Operating System version to use (e.g. 7.3 for RHEL or 16.04 for Ubuntu), defaults to "7.3".
- `vpc_id`: [Required] VPC ID to provision resources in.
- `vpc_cidr`: [Optional] VPC CIDR block to provision resources in.
- `subnet_ids`: [Optional] Subnet ID(s) to provision resources in.
- `lb_cidr_blocks`: [Optional] List of CIDR blocks to set on LB, defaults to "vpc_cidr".
- `lb_internal`: [Optional] Creates an internal load balancer, defaults to true.
- `count`: [Optional] Number of HashiStack nodes to provision across private subnets, defaults to private subnet count.
- `instance_type`: [Optional] AWS instance type for Consul node (e.g. "m4.large"), defaults to "t2.small".
- `image_id`: [Optional] AMI to use, defaults to the HashiStack AMI.
- `instance_profile`: [Optional] AWS instance profile to use.
- `user_data`: [Optional] user_data script to pass in at runtime.
- `ssh_key_name`: [Required] Name of AWS keypair that will be created.
- `lb_use_cert`: [Optional] Use certificate passed in for the LB IAM listener, "lb_cert" and "lb_private_key" must be passed in if true, defaults to false.
- `lb_cert`: [Optional] Certificate for LB IAM server certificate.
- `lb_private_key`: [Optional] Private key for LB IAM server certificate.
- `lb_cert_chain`: [Optional] Certificate chain for LB IAM server certificate.
- `lb_ssl_policy`: [Optional] SSL policy for LB, defaults to "ELBSecurityPolicy-2016-08".
- `lb_bucket`: [Optional] S3 bucket override for LB access logs, `lb_bucket_override` be set to true if overriding.
- `lb_bucket_override`: [Optional] Override the default S3 bucket created for access logs, defaults to false, `lb_bucket` _must_ be set if true.
- `lb_bucket_prefix`: [Optional] S3 bucket prefix for LB access logs.
- `lb_logs_enabled`: [Optional] S3 bucket LB access logs enabled, defaults to true.
- `target_groups`: [Optional] List of target group ARNs to apply to the autoscaling group..
- `users`: [Optional] Map of SSH users.
- `tags`: [Optional] Optional list of tag maps to set on resources, defaults to empty list.
- `tags_list`: [Optional] Optional map of tags to set on resources, defaults to empty map.

## Outputs

- `hashistack_asg_id`: HashiStack autoscaling group ID.
- `consul_sg_id`: Consul security group ID.
- `consul_app_lb_sg_id`: Consul application load balancer security group ID.
- `consul_lb_arn`: Consul application load balancer ARN.
- `consul_app_lb_dns`: Consul load balancer DNS name.
- `consul_network_lb_dns`: Consul load balancer DNS name.
- `consul_tg_tcp_22_arn`: Consul network load balancer TCP 22 target group.
- `consul_tg_tcp_8500_arn`: Consul network load balancer TCP 8500 target group.
- `consul_tg_http_8500_arn`: Consul application load balancer HTTP 8500 target group.
- `consul_tg_tcp_8080_arn`: Consul network load balancer TCP 8080 target group.
- `consul_tg_https_8080_arn`: Consul application load balancer HTTPS 8080 target group.
- `consul_tg_http_3030_arn`: Consul application load balancer HTTP 3030 target group.
- `consul_tg_https_3030_arn`: Consul application load balancer HTTPS 3030 target group.
- `vault_sg_id`: Vault security group ID.
- `vault_app_lb_sg_id`: Vault application load balancer security group ID.
- `vault_lb_arn`: Vault application load balancer ARN.
- `vault_app_lb_dns`: Vault load balancer DNS name.
- `vault_network_lb_dns`: Vault load balancer DNS name.
- `vault_tg_tcp_22_arn`: Vault network load balancer TCP 22 target group.
- `vault_tg_tcp_8200_arn`: Vault network load balancer TCP 8200 target group.
- `vault_tg_http_8200_arn`: Vault application load balancer HTTP 8200 target group.
- `vault_tg_https_8200_arn`: Vault application load balancer HTTPS 8200 target group.
- `vault_tg_http_3030_arn`: Vault application load balancer HTTP 3030 target group.
- `vault_tg_https_3030_arn`: Vault application load balancer HTTPS 3030 target group.
- `nomad_sg_id`: Nomad security group ID.
- `nomad_app_lb_sg_id`: Nomad application load balancer security group ID.
- `nomad_lb_arn`: Nomad application load balancer ARN.
- `nomad_app_lb_dns`: Nomad load balancer DNS name.
- `nomad_network_lb_dns`: Nomad load balancer DNS name.
- `nomad_tg_tcp_22_arn`: Nomad network load balancer TCP 22 target group.
- `nomad_tg_tcp_4646_arn`: Nomad network load balancer TCP 4646 target group.
- `nomad_tg_http_4646_arn`: Nomad application load balancer HTTP 4646 target group.
- `nomad_tg_https_4646_arn`: Nomad application load balancer HTTPS 4646 target group.
- `nomad_tg_http_3030_arn`: Nomad application load balancer HTTP 3030 target group.
- `nomad_tg_https_3030_arn`: Nomad application load balancer HTTPS 3030 target group.
- `hashistack_username`: The HashiStack host username.

## Submodules

- [AWS HashiStack Server Ports Terraform Module](https://github.com/hashicorp-modules/hashistack-server-ports-aws)

## Recommended Modules

These are recommended modules you can use to populate required input variables for this module. The sub-bullets show the mapping of output variable --> required input variable for the respective modules.

- [AWS SSH Keypair Terraform Module](https://github.com/hashicorp-modules/ssh-keypair-aws)
  - `ssh_key_name` --> `ssh_key_name`
- [AWS Network Terraform Module](https://github.com/hashicorp-modules/network-aws/)
  - `vpc_cidr` --> `vpc_cidr`
  - `vpc_id` --> `vpc_id`
  - `subnet_private_ids` --> `subnet_ids`
- [AWS HashiStack Server Ports Terraform Module](https://github.com/hashicorp-modules/hashistack-server-ports-aws)

## Image Dependencies

- [hashistack.json Packer template](https://github.com/hashicorp/guides-configuration/blob/master/hashistack/hashistack.json)

## Authors

HashiCorp Solutions Engineering Team.

## License

Mozilla Public License Version 2.0. See LICENSE for full details.
