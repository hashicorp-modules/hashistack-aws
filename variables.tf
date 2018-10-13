variable "create" {
  description = "Create Module, defaults to true."
  default     = true
}

variable "name" {
  description = "Name for resources, defaults to \"vault-aws\"."
  default     = "vault-aws"
}

variable "ami_owner" {
  description = "Account ID of AMI owner."
  default     = "012230895537" # HashiCorp Public AMI AWS account
}

variable "release_version" {
  description = "Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1), defaults to \"0.1.0\", view releases at https://github.com/hashicorp/guides-configuration#hashistack-version-tables"
  default     = "0.1.0"
}

variable "consul_version" {
  description = "Consul version tag (e.g. 1.2.3 or 1.2.3-ent), defaults to \"1.2.3\"."
  default     = "1.2.3"
}

variable "vault_version" {
  description = "Vault version tag (e.g. 0.11.3 or 0.11.3-ent), defaults to \"0.11.3\"."
  default     = "0.11.3"
}

variable "nomad_version" {
  description = "Nomad version tag (e.g. 0.8.6 or 0.8.6-ent), defaults to \"0.8.6\"."
  default     = "0.8.6"
}

variable "os" {
  description = "Operating System (e.g. RHEL or Ubuntu), defaults to \"RHEL\"."
  default     = "RHEL"
}

variable "os_version" {
  description = "Operating System version (e.g. 7.3 for RHEL or 16.04 for Ubuntu), defaults to \"7.3\"."
  default     = "7.3"
}

variable "vpc_id" {
  description = "VPC ID to provision resources in."
}

variable "vpc_cidr" {
  description = "VPC CIDR block to provision resources in."
}

variable "subnet_ids" {
  description = "Subnet ID(s) to provision resources in."
  type        = "list"
}

variable "public" {
  description = "Open up nodes to the public internet for easy access - DO NOT DO THIS IN PROD, defaults to false."
  default     = false
}

variable "count" {
  description = "Number of HashiStack nodes to provision across private subnets, defaults to private subnet count."
  default     = -1
}

variable "instance_type" {
  description = "AWS instance type for HashiStack node (e.g. \"m4.large\"), defaults to \"t2.small\"."
  default     = "t2.small"
}

variable "image_id" {
  description = "AMI to use, defaults to the HashiStack AMI."
  default     = ""
}

variable "instance_profile" {
  description = "AWS instance profile to use."
  default     = ""
}

variable "user_data" {
  description = "user_data script to pass in at runtime."
  default     = ""
}

variable "ssh_key_name" {
  description = "AWS key name you will use to access the instance(s)."
}

variable "use_lb_cert" {
  description = "Use certificate passed in for the LB IAM listener, \"lb_cert\" and \"lb_private_key\" must be passed in if true, defaults to false."
  default     = false
}

variable "lb_cert" {
  description = "Certificate for LB IAM server certificate."
  default     = ""
}

variable "lb_private_key" {
  description = "Private key for LB IAM server certificate."
  default     = ""
}

variable "lb_cert_chain" {
  description = "Certificate chain for LB IAM server certificate."
  default     = ""
}

variable "lb_ssl_policy" {
  description = "SSL policy for LB, defaults to \"ELBSecurityPolicy-2016-08\"."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "lb_bucket" {
  description = "S3 bucket override for LB access logs, `lb_bucket_override` be set to true if overriding"
  default     = ""
}

variable "lb_bucket_override" {
  description = "Override the default S3 bucket created for access logs with `lb_bucket`, defaults to false."
  default     = false
}

variable "lb_bucket_prefix" {
  description = "S3 bucket prefix for LB access logs."
  default     = ""
}

variable "lb_logs_enabled" {
  description = "S3 bucket LB access logs enabled, defaults to true."
  default     = true
}

variable "target_groups" {
  description = "List of target group ARNs to apply to the autoscaling group."
  type        = "list"
  default     = []
}

variable "users" {
  description = "Map of SSH users."

  default = {
    RHEL   = "ec2-user"
    Ubuntu = "ubuntu"
  }
}

variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = "map"
  default     = {}
}

variable "tags_list" {
  description = "Optional list of tag maps to set on resources, defaults to empty list."
  type        = "list"
  default     = []
}
