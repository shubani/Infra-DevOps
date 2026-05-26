output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "application_url" {
  value       = "http://${aws_lb.main.dns_name}"
  description = "Access the Mandi application using this URL"
}