resource "aws_subnet" "private_subnets" {
  count             = length(local.private_subnets)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(local.azs, count.index)
  cidr_block        = element(local.private_subnets, count.index)

  tags = {
    Name = format("%s-private-%s", var.project_name, substr(element(local.azs, count.index), -2, -1))
  }
}

resource "aws_route_table_association" "privates" {
  count          = length(local.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.nat.id
}