resource "aws_subnet" "public_subnets" {
  count                   = length(local.public_subnets)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone       = element(local.azs, count.index)
  cidr_block              = element(local.public_subnets, count.index)

  tags = {
    Name = format("%s-public-%s", var.project_name, substr(element(local.azs, count.index), -2, -1))
  }
}

resource "aws_route_table_association" "publics" {
  count          = length(local.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.igw_route_table.id
}