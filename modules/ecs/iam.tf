# ECS Instance Role
# -----------------

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.name}_${var.environment}_ecs_instance_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_policy.json
}

data "aws_iam_policy_document" "ecs_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "ecs_instance_settings" {
  name        = "${var.name}_${var.environment}_ecs_instance_settings"
  path        = "/"
  description = "Additional permissions for ECS backing instances"

  policy = data.aws_iam_policy_document.ecs_instance_settings.json
}

data "aws_iam_policy_document" "ecs_instance_settings" {
  statement {
    sid = "ecsinstancesettings1"
    actions = [
      "kms:*",
      "ses:*",
      "cognito-idp:*",
      "s3:*",
      "elasticloadbalancing:*",
      "acm:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_settings" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_instance_settings.arn
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.name}_${var.environment}_ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs_instance_role.name
}

# ECS Service Role
# ----------------

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.name}_${var.environment}_ecs_service_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_role" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}