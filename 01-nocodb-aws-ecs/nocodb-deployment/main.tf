provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket  = "my-nocodb-tf-state-secondjunko"
    key     = "state/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}

# --------------------
# Variables
# --------------------
variable "ecr_image" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "private_subnet_a_id" {
  description = "ID du subnet privé A"
  type        = string
}

variable "private_subnet_b_id" {
  description = "ID du subnet privé B"
  type        = string
}

variable "nocodb_security_group_id" {
  description = "ID du security group NocoDB"
  type        = string
}

variable "ecs_target_group_arn" {
  description = "ARN du target group ECS"
  type        = string
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

variable "jwt_secret" {
  description = "JWT secret key for NocoDB auth"
  type        = string
  sensitive   = true
}

# --------------------
# Logs + ECS infra
# --------------------
resource "aws_cloudwatch_log_group" "quickdata_logs" {
  name              = "/ecs/quickdata"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "ECS" {
  name = "${var.app_name}-cluster"
}

resource "aws_iam_role" "task_execution_role" {
  name = "${var.app_name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ECS" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "nocodb"
    image     = var.ecr_image
    essential = true
    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "NC_PORT"
        value = tostring(var.container_port)
      },
      {
        name  = "NC_DB_HOST"
        value = var.rds_endpoint
      },
      {
        name  = "NC_AUTH_JWT_SECRET"
        value = var.jwt_secret
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/quickdata"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "quickdata"
      }
    }
  }])

  depends_on = [aws_cloudwatch_log_group.quickdata_logs]
}

resource "aws_ecs_service" "ECS" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.ECS.id
  task_definition = aws_ecs_task_definition.ECS.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [var.private_subnet_a_id, var.private_subnet_b_id]
    assign_public_ip = false
    security_groups  = [var.nocodb_security_group_id]
  }

  load_balancer {
    target_group_arn = var.ecs_target_group_arn
    container_name   = "nocodb"
    container_port   = var.container_port
  }

  depends_on = [
    aws_ecs_task_definition.ECS
  ]
}

# ----------------------------
# Autoscaling ECS (si activé)
# ----------------------------
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ECS.name}/${aws_ecs_service.ECS.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "memory_policy" {
  name               = "memory-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 0
    scale_out_cooldown = 60
  }
}
