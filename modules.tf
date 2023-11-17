module "network" {
  source = "./modules/network"

  aws_region   = var.aws_region
  project_name = var.project_name
}

module "ecs" {
  source = "./modules/ecs"

  aws_region          = var.aws_region
  project_name        = var.project_name
  aws_vpc             = module.network.vpc
  instance_type       = "t2.micro"
  desired_capacity    = 2
  min_size            = 0
  max_size            = 10
  vpc_zone_identifier = [module.network.private_subnet_1a.id, module.network.private_subnet_1c.id]
}
