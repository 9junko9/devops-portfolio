provider "aws" {
  region = var.aws_region
}

# ----------------------------
# Variables
# ----------------------------
variable "db_username" {
  type    = string
  default = "mydb"
}
variable "db_password" {
  description = "Mot de passe PostgreSQL (sensitif)"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  default = "eu-west-3"
}
variable "app_name" {
  default = "nocodb-app"
}
variable "container_port" {
  default = 8080
}

# ----------------------------
# Terraform backend S3
# ----------------------------
terraform {
  backend "s3" {
    bucket = "my-nocodb-tf-state-secondjunko"
    key    = "state/rds.tfstate"
    region = "eu-west-3"
    encrypt = true
  }
}

# ----------------------------
# ECR Repository
# ----------------------------
resource "aws_ecr_repository" "nocodb" {
  name                 = "nocodb"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ----------------------------
# Réseau VPC / Subnets
# ----------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# ----------------------------
# ALB
# ----------------------------
resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.https_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# HTTP Listener → Redirection vers HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"
    }
  }
}

# ----------------------------
# Security Groups
# ----------------------------
resource "aws_security_group" "alb_sg" {
  name   = "${var.app_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nocodb_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow traffic only from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-rds-sg"
  description = "Allow PostgreSQL access from NocoDB ECS SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.nocodb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------
# RDS
# ----------------------------
resource "aws_db_subnet_group" "nocodb_db_subnet_group" {
  name       = "nocodb-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "nocodb-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier               = "quickdata-postgres"
  engine                   = "postgres"
  engine_version           = "14.17"
  instance_class           = "db.t3.micro"
  allocated_storage        = 20
  username                 = var.db_username
  password                 = var.db_password
  skip_final_snapshot      = true
  final_snapshot_identifier = "quickdata-postgres-final"
  backup_retention_period  = 5
  backup_window            = "02:00-02:30"
  publicly_accessible      = false
  db_subnet_group_name     = aws_db_subnet_group.nocodb_db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]

  tags = {
    Name = "quickdata-postgres-prod"
  }
}

# ----------------------------
# Certificat ACM
# ----------------------------
resource "aws_acm_certificate" "https_cert" {
  domain_name       = "quickdata-db.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "quickdata-cert"
  }
}

# ----------------------------
# Outputs
# ----------------------------
output "ecr_repository_url" {
  value = aws_ecr_repository.nocodb.repository_url
}
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
output "vpc_id" {
  value = aws_vpc.main.id
}
output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}
output "private_subnet_b_id" {
  value = aws_subnet.private_b.id
}
output "nocodb_security_group_id" {
  value = aws_security_group.nocodb_sg.id
}
output "ecs_target_group_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
output "acm_validation_name" {
  value = tolist(aws_acm_certificate.https_cert.domain_validation_options)[0].resource_record_name
}

output "acm_validation_value" {
  value = tolist(aws_acm_certificate.https_cert.domain_validation_options)[0].resource_record_value
}
