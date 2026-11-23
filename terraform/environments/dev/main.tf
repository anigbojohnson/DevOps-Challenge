
locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "networking" {
  source      = "../../modules/networking"
  name        = local.name
  vpc_cidr    = var.vpc_cidr
  subnet_tags = local.common_tags
  environment = var.environment
}

module "security" {
  source = "../../modules/security"

  name           = local.name
  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
}

module "ecr" {
  source = "../../modules/ecr"

  name = local.name
}

module "database" {
  source = "../../modules/database"

  multi_az          = false
  name              = local.name
  subnet_ids        = module.networking.private_subnet_ids
  database_name     = var.database_name
  database_username = var.database_username
  security_group_id = module.security.database_security_group_id

  instance_class = "db.t4g.micro"


  tags = local.common_tags
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  name              = local.name
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.public_subnet_ids
  security_group_id = module.security.alb_security_group_id
  container_port    = var.container_port
  domain_name       = var.domain_name

}

module "ecs" {
  source = "../../modules/ecs"

  name           = local.name
  aws_region     = var.aws_region
  repository_url = module.ecr.repository_url

  min_capacity = 1
  max_capacity = 3

  task_cpu    = 256
  task_memory = 512

  log_group_name = module.monitoring.ecs_log_group_name


  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.security.ecs_security_group_id

  container_port = var.container_port

  database_endpoint   = module.database.database_endpoint
  database_name       = var.database_name
  database_username   = var.database_username
  database_secret_arn = module.database.database_secret_arn

  target_group_arn = module.load_balancer.target_group_arn

  desired_count = 1
}

module "monitoring" {
  source = "../../modules/monitoring"


  name       = local.name
  aws_region = var.aws_region
  alarm_email = var.alarm_email 


  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name

  database_instance_identifier = module.database.database_instance_identifier

  load_balancer_arn_suffix = module.load_balancer.load_balancer_arn_suffix
  target_group_arn_suffix  = module.load_balancer.target_group_arn_suffix
}


module "github_oidc" {
  source = "../../modules/github_oidc"

  github_owner      = var.github_owner
  github_repository = var.github_repository
  github_branch     = var.github_branch

  ecr_repository_arn = module.ecr.repository_arn

  ecs_cluster_arn         = module.ecs.cluster_arn
  ecs_service_arn         = module.ecs.service_arn
  ecs_task_definition_arn = module.ecs.task_definition_arn

  ecs_execution_role_arn = module.ecs.execution_role_arn
  ecs_task_role_arn      = module.ecs.ecs_task_role_arn

  github_owner_id      = var.github_owner_id
  github_repository_id = var.github_repository_id
}