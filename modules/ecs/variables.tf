variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type    = string
  default = "ecs"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

# variable "top_level_domain" {
#   type = string
# }

# variable "key_name" {
#   type = string
# }

variable "volume_size" {
  type    = number
  default = 30
}

variable "max_instances" {
  type    = number
  default = 2
}

variable "min_instances" {
  type    = number
  default = 1
}

variable "desired_instances" {
  type    = number
  default = 1
}

variable "single_balancer" {
  type        = bool
  default     = true
  description = "Create a single load balancer to serve the entire ECS cluster."
}

variable "vpn_security_groups" {
  type = list(string)
}

locals {
  common_tags = {
    Namespace     = var.namespace
    Environment   = var.environment
    Name          = "${var.namespace}-${var.environment}-${var.name}"
    ProvisionedBy = "terraform"
  }
}