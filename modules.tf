module "network" {
  source = "./modules/network"

  azs_count    = 2
  vpc_cidr     = "10.0.0.0/16"
  aws_region   = var.aws_region
  project_name = var.project_name
}

# module "ecs" {
#   source = "./modules/ecs"

#   aws_region          = var.aws_region
#   project_name        = var.project_name
#   aws_vpc             = module.network.vpc
#   instance_type       = "t3.micro"
#   desired_capacity    = 2
#   min_size            = 0
#   max_size            = 10
#   vpc_zone_identifier = [module.network.private_subnet_1a.id, module.network.private_subnet_1c.id]
# }

# module "otel-service" {
#   source = "./modules/ecs-services/otel"

#   aws_region              = var.aws_region
#   ecs_task_execution_role = module.ecs.ecs_task_execution_role
#   ecs_task_role           = module.ecs.ecs_task_role
#   ecs_cluster             = module.ecs.ecs_cluster

#   private_subnets = [
#     module.network.private_subnet_1a.id,
#     module.network.private_subnet_1c.id
#   ]

#   security_groups = [
#     module.ecs.security_group.id
#   ]
# }
