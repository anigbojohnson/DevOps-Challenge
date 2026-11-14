
output "load_balancer_dns" {
  value = aws_lb.app.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.app.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "load_balancer_arn_suffix" {
  value = aws_lb.app.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.app.arn_suffix
}

output "certificate_validation_options" {
  description = "DNS records required to validate the ACM certificate"
  value       = aws_acm_certificate.app.domain_validation_options
}