
output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "database_endpoint" {
  value = module.database.database_endpoint
}



output "application_url" {
  description = "Public Todo application URL"
  value       = "http://${module.load_balancer.load_balancer_dns}"
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "certificate_validation_options" {
  description = "DNS records required to validate the ACM certificate"
  value       = module.load_balancer.certificate_validation_options
}

output "github_actions_role_arn" {
  description = "IAM role ARN to configure in GitHub Actions"
  value       = module.github_oidc.github_actions_role_arn
}