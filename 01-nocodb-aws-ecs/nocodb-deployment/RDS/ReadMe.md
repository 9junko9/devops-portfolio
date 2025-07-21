# Module Terraform RDS / VPC / ALB

Ce dossier déploie l’infrastructure principale pour l’application NocoDB :

- VPC + Subnets publics et privés
- NAT Gateway
- ALB avec HTTPS (certificat ACM)
- RDS PostgreSQL
- ECR pour héberger l’image Docker

##  Variables principales

- `db_username`
- `db_password`
- `app_name`
- `aws_region`

##  Outputs

- `ecr_repository_url`
- `rds_endpoint`
- `alb_dns_name`
- `ecs_target_group_arn`
- `private_subnet_a_id`
- `private_subnet_b_id`
- `nocodb_security_group_id`

## ▶ Commandes utiles

```bash
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
