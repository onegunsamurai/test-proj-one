
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.default.id
}

# output "igw_id" {
#   description = "The Gateway ID of the VPC"
#   value       = aws_internet_gateway.default.id
# }

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = aws_subnet.private.*.id
}

output "default_security_group_id" {
  description = "The default security group from the VPC"
  value       = aws_vpc.default.default_security_group_id
}