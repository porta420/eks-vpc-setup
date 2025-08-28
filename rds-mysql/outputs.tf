output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}

output "rds_db_name" {
  value = aws_db_instance.mysql.db_name
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

# For convenience when wiring your K8s ConfigMap/Secret
output "spring_datasource_url" {
  value = "jdbc:mysql://${aws_db_instance.mysql.address}:${aws_db_instance.mysql.port}/${aws_db_instance.mysql.db_name}?useSSL=false&serverTimezone=UTC"
}
