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

# VPC

resource "aws_vpc" "default" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6
  tags                             = module.label.tags
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "Default Security Group"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags   = module.label.tags
}

# Subnets

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.max_subnet_count == 0 ? length(data.aws_availability_zones.available.names) : var.max_subnet_count)
  private_subnet_count = var.max_subnet_count == 0 ? length(data.aws_availability_zones.available.names) : var.max_subnet_count
  public_subnet_count = var.max_subnet_count == 0 ? length(data.aws_availability_zones.available.names) : var.max_subnet_count
}

# Private subnets

module "private_label" {
  source     = "../label"
  namespace  = var.namespace
  stage      = var.environment
  name       = var.name
  delimiter  = "-"
  attributes = compact(concat(module.label.attributes, ["private"]))
  profile   = var.profile
  region    = var.region

  tags = merge(
    module.label.tags,
    tomap({"Type" = "private"})
  )
}

resource "aws_subnet" "private" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.default.id
  availability_zone = element(local.availability_zones, count.index)

  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : aws_vpc.default.cidr_block,
    ceil(log(local.private_subnet_count * 2, 2)),
    count.index
  )

  tags = merge(
    module.private_label.tags,
    {
      "Name" = format(
        "%s%s%s",
        module.private_label.id,
        module.private_label.delimiter,
        replace(
          element(local.availability_zones, count.index),
          "-",
          module.private_label.delimiter
        )
      )
    }
  )
}

resource "aws_route_table" "private" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = merge(
    module.private_label.tags,
    {
      "Name" = format(
        "%s%s%s",
        module.private_label.id,
        module.private_label.delimiter,
        replace(
          element(local.availability_zones, count.index),
          "-",
          module.private_label.delimiter
        )
      )
    }
  )
}

resource "aws_route_table_association" "private" {
  count = length(local.availability_zones)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_network_acl" "private" {
  count      = signum(length(var.private_network_acl_id)) == 0 ? 1 : 0
  vpc_id     = aws_vpc.default.id
  subnet_ids = aws_subnet.private.*.id

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  tags = module.private_label.tags
}

# Public subnets

module "public_label" {
  source     = "../label"
  namespace  = var.namespace
  stage      = var.environment
  name       = var.name
  delimiter  = "-"
  attributes = compact(concat(module.label.attributes, ["public"]))
  profile   = var.profile
  region    = var.region

  tags = merge(
    module.label.tags,
    tomap({"Type" = "public"})
  )
}

resource "aws_subnet" "public" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.default.id
  availability_zone = element(local.availability_zones, count.index)

  cidr_block = cidrsubnet(
    signum(length(var.cidr_block)) == 1 ? var.cidr_block : aws_vpc.default.cidr_block,
    ceil(log(local.public_subnet_count * 2, 2)),
    local.public_subnet_count + count.index
  )

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    module.public_label.tags,
    {
      "Name" = format(
        "%s%s%s",
        module.public_label.id,
        module.public_label.delimiter,
        replace(
          element(local.availability_zones, count.index),
          "-",
          module.public_label.delimiter
        )
      )
    }
  )
}

resource "aws_route_table" "public" {
  count  = signum(length(var.vpc_default_route_table_id)) == 1 ? 0 : 1
  vpc_id = aws_vpc.default.id

  tags = module.public_label.tags
}

resource "aws_route" "public" {
  count                  = signum(length(var.vpc_default_route_table_id)) == 1 ? 0 : 1
  route_table_id         = join("", aws_route_table.public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  count          = signum(length(var.vpc_default_route_table_id)) == 1 ? 0 : length(local.availability_zones)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "public_default" {
  count          = signum(length(var.vpc_default_route_table_id)) == 1 ? length(local.availability_zones) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = var.vpc_default_route_table_id
}

resource "aws_network_acl" "public" {
  count      = signum(length(var.public_network_acl_id)) == 0 ? 1 : 0
  vpc_id     = aws_vpc.default.id
  subnet_ids = aws_subnet.public.*.id

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  tags = module.public_label.tags
}