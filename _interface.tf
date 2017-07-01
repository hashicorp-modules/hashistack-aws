# Required variables
variable "cluster_name" {
  description = "Auto Scaling Group Cluster Name"
}

variable "environment_name" {
  description = "Environment Name (tagged to all instances)"
}

variable "os" {
  # case sensitive for AMI lookup
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

variable "ssh_key_name" {
  description = "Pre-existing AWS key name you will use to access the instance(s)"
}

variable "subnet_ids" {
  type        = "list"
  description = "Pre-existing Subnet ID(s) to use"
}

variable "vpc_id" {
  description = "Pre-existing VPC ID to use"
}

# Optional variables
variable "cluster_size" {
  default     = "3"
  description = "Number of instances to launch in the cluster"
}

variable "consul_version" {
  default     = "0.8.4"
  description = "Consul version to use ie 0.8.4"
}

variable "nomad_version" {
  default     = "0.5.6"
  description = "Nomad version to use ie 0.5.6"
}

variable "vault_version" {
  default     = "0.7.2"
  description = "Vault version to use ie 0.7.1"
}

variable "instance_type" {
  default     = "m4.large"
  description = "AWS instance type to use eg m4.large"
}

variable "region" {
  default     = "us-west-1"
  description = "Region to deploy consul cluster ie us-west-1"
}

# Outputs
output "asg_id" {
  value = "${aws_autoscaling_group.hashistack_server.id}"
}

output "consul_client_sg_id" {
  value = "${aws_security_group.consul_client.id}"
}

output "hashistack_server_sg_id" {
  value = "${aws_security_group.hashistack_server.id}"
}
