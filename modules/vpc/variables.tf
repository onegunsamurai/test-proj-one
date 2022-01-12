variable "region" {
  type = string
  description = "Resource region"
}

variable "profile" {
  type = string
  description = "AWS Profile" #May be removed after testing
}

variable "namespace" {
  type = string
  description = "Resource namespace"
}

variable "environment" {
  type = string
  description = "Resource environment"
}

variable "name" {
  type    = string
  description = "Resource name"
  default = "vpc"
}

variable "cidr_block" {
  type        = string
  description = "CIDR for the VPC"
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC"
}

variable "enable_classiclink" {
  type        = bool
  description = "A boolean flag to enable/disable ClassicLink for the VPC"
}

variable "enable_classiclink_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable ClassicLink DNS Support for the VPC"
  default     = false
}

variable "enable_ipv6" {
  type        = bool
  description = "A boolean flag to enable/disable IPv6 Support for the VPC"
  default     = true
}

variable "max_subnet_count" {
  default     = 0
  type        = number
  description = "Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region"
}

variable "vpc_default_route_table_id" {
  type        = string
  default     = ""
  description = "Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`)"
}

variable "public_network_acl_id" {
  type        = string
  default     = ""
  description = "Network ACL ID that will be added to public subnets. If empty, a new ACL will be created"
}

variable "private_network_acl_id" {
  type        = string
  description = "Network ACL ID that will be added to private subnets. If empty, a new ACL will be created"
  default     = ""
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Instances launched into a public subnet should be assigned a public IP address"
}

locals {
  common_tags = {
    Namespace     = var.namespace
    Environment   = var.environment
    Name          = "${var.namespace}-${var.environment}-${var.name}"
    ProvisionedBy = "terraform"
  }
}