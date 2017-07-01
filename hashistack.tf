terraform {
  required_version = ">= 0.9.3"
}

module "images-aws" {
  source         = "git@github.com:hashicorp-modules/images-aws.git"
  nomad_version  = "${var.nomad_version}"
  vault_version  = "${var.vault_version}"
  consul_version = "${var.consul_version}"
  aws_region     = "${var.region}"
  os             = "${var.os}"
  os_version     = "${var.os_version}"
}

resource "aws_iam_role" "hashistack_server" {
  name               = "${var.cluster_name}-HashiStack-Server"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "hashistack_server" {
  name   = "SelfAssembly"
  role   = "${aws_iam_role.hashistack_server.id}"
  policy = "${data.aws_iam_policy_document.hashistack_server.json}"
}

resource "aws_iam_instance_profile" "hashistack_server" {
  name = "${var.cluster_name}-HashiStack-Server"
  role = "${aws_iam_role.hashistack_server.name}"
}

data "template_file" "init" {
  template = "${file("${path.module}/init-cluster.tpl")}"

  vars = {
    cluster_size     = "${var.cluster_size}"
    environment_name = "${var.environment_name}"
  }
}

resource "aws_launch_configuration" "hashistack_server" {
  image_id      = "${module.images-aws.hashistack_image}"
  instance_type = "${var.instance_type}"
  user_data     = "${data.template_file.init.rendered}"
  key_name      = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.hashistack_server.id}",
    "${aws_security_group.consul_client.id}",
  ]

  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.hashistack_server.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "hashistack_server" {
  launch_configuration = "${aws_launch_configuration.hashistack_server.id}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  name                 = "${var.cluster_name} HashiStack Servers"
  max_size             = "${var.cluster_size}"
  min_size             = "${var.cluster_size}"
  desired_capacity     = "${var.cluster_size}"
  default_cooldown     = 30
  force_delete         = true

  tag {
    key                 = "Name"
    value               = "${format("%s Hashistack Server", var.cluster_name)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster-Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment-Name"
    value               = "${var.environment_name}"
    propagate_at_launch = true
  }
}
