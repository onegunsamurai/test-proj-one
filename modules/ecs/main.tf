module "label" {
  source    = "../label"
  namespace = var.namespace
  stage     = var.environment
  name      = var.name
  tags      = local.common_tags
  delimiter = "-"
  profile   = var.profile
  region    = var.region
}

resource "aws_ecs_cluster" "ecs" {
  name = module.label.id

  tags = module.label.tags
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh")

  vars = {
    cluster_name = aws_ecs_cluster.ecs.name
  }
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "ecs" {
  name        = module.label.id
  description = "Allow traffic to ECS instances"
  vpc_id      = var.vpc_id

  tags = module.label.tags
}

resource "aws_security_group_rule" "ecs_allow_balancer" {
  description     = "Allow traffic from Load Balancer"
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  source_security_group_id = module.balancer.security_group_id
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_allow_vpn" {
  count           = length(var.vpn_security_groups)
  description     = "SSH Access from the OpenVPN server"
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  source_security_group_id = element(var.vpn_security_groups, count.index)
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_outbound" {
  description     = "Allow internet outbound"
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_launch_configuration" "ecs" {
  name_prefix                 = module.label.id
  image_id                    = data.aws_ami.ecs_ami.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ecs.id
  security_groups             = [aws_security_group.ecs.id]
  # key_name                    = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = data.template_file.userdata.rendered
}

resource "aws_autoscaling_group" "autoscale" {
  name             = module.label.id
  max_size         = var.max_instances
  min_size         = var.min_instances
  desired_capacity = var.desired_instances

  vpc_zone_identifier  = var.public_subnet_ids
  launch_configuration = aws_launch_configuration.ecs.name
  health_check_type    = "ELB"

  tag {
    key                 = "ProvisionedBy"
    value               = "terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = module.label.id
    propagate_at_launch = true
  }
}

module "balancer" {
  source            = "../balancer"
  region            = var.region
  namespace         = var.namespace
  environment       = var.environment
  name              = "${var.name}-LB"
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
  # top_level_domain  = var.top_level_domain
  # subdomain         = module.label.id
  enabled           = var.single_balancer
  profile           = var.profile
}