data "aws_availability_zones" "available" {}

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, var.azs_count)
  private_subnets = [ for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k) ]
  public_subnets  = [ for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + var.azs_count) ]
}