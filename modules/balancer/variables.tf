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
  default = "balancer"
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

# variable "subdomain" {
#   type = string
# }

variable "enabled" {
  type    = bool
  default = true
}

locals {
  common_tags = {
    Namespace     = var.namespace
    Environment   = var.environment
    Name          = "${var.namespace}-${var.environment}-${var.name}"
    ProvisionedBy = "terraform"
  }

  # full_domain = "${var.subdomain}.${var.top_level_domain}"
}