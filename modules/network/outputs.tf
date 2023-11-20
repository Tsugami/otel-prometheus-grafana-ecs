output "vpc" {
  value = aws_vpc.main
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "security_group" {
  value = aws_security_group.default
}
