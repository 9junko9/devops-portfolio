output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Liste des IDs des subnets publics"
  value       = aws_subnet.public[*].id
}
