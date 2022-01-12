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

resource "aws_security_group" "alb" {
  count = var.enabled ? 1 : 0

  name        = module.label.id
  description = "Allow traffic from ports 80 and 443"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    ipv6_cidr_blocks = ["::/0"]
    description      = "HTTP access from anywhere IP v6"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access from anywhere"
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    ipv6_cidr_blocks = ["::/0"]
    description      = "HTTPS access from anywhere IP v6"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound traffic anywhere"
  }

  tags = module.label.tags
}

resource "aws_lb" "alb" {
  count = var.enabled ? 1 : 0

  name               = module.label.id
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.0.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = module.label.tags
}

# resource "aws_lb_listener" "http" {
#   count = var.enabled ? 1 : 0

#   load_balancer_arn = aws_lb.alb.0.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }

#   depends_on = [aws_lb.alb]
# }

# data "aws_route53_zone" "zone" {
#   name = "${var.top_level_domain}."
# }

# resource "aws_route53_record" "alb" {
#   count = var.enabled ? 1 : 0

#   zone_id = data.aws_route53_zone.zone.zone_id
#   name    = local.full_domain
#   type    = "A"

#   alias {
#     name                   = aws_lb.alb.0.dns_name
#     zone_id                = aws_lb.alb.0.zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_acm_certificate" "default" {
#   count = var.enabled ? 1 : 0

#   domain_name       = aws_route53_record.alb.0.name
#   validation_method = "DNS"

#   tags = module.label.tags

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "default_validation" {
#   count = var.enabled ? 1 : 0

#   name    = aws_acm_certificate.default.0.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.default.0.domain_validation_options.0.resource_record_type
#   zone_id = data.aws_route53_zone.zone.zone_id
#   records = [aws_acm_certificate.default.0.domain_validation_options.0.resource_record_value]
#   ttl     = 60
# }

# resource "aws_acm_certificate_validation" "default" {
#   count = var.enabled ? 1 : 0

#   certificate_arn         = aws_acm_certificate.default.0.arn
#   validation_record_fqdns = [aws_route53_record.default_validation.0.fqdn]
# }

resource "aws_lb_listener" "alb" {
  count = var.enabled ? 1 : 0

  load_balancer_arn = aws_lb.alb.0.arn
  port              = "80"     # Replace with 443
  protocol          = "HTTP"   # Replace with HTTPS
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = aws_acm_certificate_validation.default.0.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ok"
      status_code  = "200"
    }
  }
}