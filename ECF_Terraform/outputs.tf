output "rds_endpoint" {
  value       = aws_db_instance.ecf_rds.endpoint
  description = "Endpoint"
}

output "ec2_public_ip" {
  value       = aws_instance.web.public_ip
  description = "ip publique"
}