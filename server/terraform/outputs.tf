output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.ldap.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.ldap.name
}

output "public_ip_instructions" {
  description = "Instructions to get the public IP"
  value       = <<EOF
To get the task's public IP:
1. Go to AWS ECS Console
2. Navigate to Clusters > ${aws_ecs_cluster.ldap.name}
3. Click on the running task
4. Check the 'Network' section for public IP
EOF
}