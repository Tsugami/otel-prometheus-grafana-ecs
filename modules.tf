module "network" {
  source = "./modules/network"

  azs_count    = 2
  vpc_cidr     = "10.0.0.0/16"
  aws_region   = var.aws_region
  project_name = var.project_name
}

module "ecs" {
  source = "./modules/ecs"

  aws_region         = var.aws_region
  project_name       = var.project_name
  aws_vpc            = module.network.vpc
  instance_type      = "t2.micro"
  desired_capacity   = 1
  min_size           = 0
  max_size           = 10
  private_subnet_ids = module.network.private_subnet_ids
}

module "otel-service" {
  source = "./modules/ecs-services/otel"

  aws_region      = var.aws_region
  ecs_cluster     = module.ecs.ecs_cluster
  private_subnets = module.network.private_subnet_ids
  # ecs_task_execution_role = module.ecs.ecs_task_execution_role
  # ecs_task_role           = module.ecs.ecs_task_role

  security_groups = [
    module.ecs.security_group.id
  ]
}

module "app-service" {
  source = "./modules/ecs-services/app"

  aws_region        = var.aws_region
  ecs_cluster       = module.ecs.ecs_cluster
  aws_vpc           = module.network.vpc
  public_subnet_ids = module.network.public_subnet_ids
  private_subnets   = module.network.private_subnet_ids
  # ecs_task_execution_role = module.ecs.ecs_task_execution_role
  # ecs_task_role           = module.ecs.ecs_task_role

  security_groups = [
    module.network.security_group.id,
    module.ecs.security_group.id
  ]
}
