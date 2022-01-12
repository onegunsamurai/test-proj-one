# output "domain" {
#   description = "The domain name used for the Route53 record"
#   value       = local.full_domain
# }

output "arn" {
  description = "The ARN of the Load Balancer"
  value       = join("", aws_lb.alb.*.arn)
}

output "listener_arn" {
  description = "The ARN of the Listener"
  value       = join("", aws_lb_listener.alb.*.arn)
}

output "dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = join("", aws_lb.alb.*.dns_name)
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = join("", aws_lb.alb.*.zone_id)
}

output "security_group_id" {
  description = "The Balancer's Security Group"
  value       = join("", aws_security_group.alb.*.id)
}