terraform {
  required_version = ">= 0.9.3"
}

data "aws_ami" "hashistack" {
  most_recent = true
  owners      = ["362381645759"] # hc-se-demos Hashicorp Demos New Account
  name_regex  = "${var.environment}-hashistack-server-${var.binary_type}-${var.os}_${var.os_version}.*"

  filter {
    name   = "tag:System"
    values = ["HashiStack"]
  }

  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }
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
  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.hashistack_server.id}"
  image_id      = "${data.aws_ami.hashistack.id}"
  instance_type = "${var.instance_type}"
  user_data     = "${data.template_file.init.rendered}"
  key_name      = "${var.ssh_key_name}"

  security_groups = [
    "${aws_security_group.hashistack_server.id}",
    "${aws_security_group.consul_client.id}",
  ]

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
    value               = "${format("%s HashiStack Server", var.cluster_name)}"
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
