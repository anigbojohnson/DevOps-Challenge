
output "database_endpoint" {
  value = aws_db_instance.postgres.address
}

output "database_port" {
  value = aws_db_instance.postgres.port
}

output "database_name" {
  value = aws_db_instance.postgres.db_name
}

output "database_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "database_instance_identifier" {
  value = aws_db_instance.postgres.id
}

