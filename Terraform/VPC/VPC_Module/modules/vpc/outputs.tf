output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the created public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "igw_id" {
  description = "The ID of the created Internet Gateway"
  value       = aws_internet_gateway.gw.id
}