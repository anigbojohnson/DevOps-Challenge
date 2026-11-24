
# ECS Task Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

# Standard ECS execution permissions
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role = aws_iam_role.ecs_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow ECS to retrieve database credentials
resource "aws_iam_role_policy" "secrets_access" {
  name = "${var.name}-secrets-access"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = var.database_secret_arn
    }]
  })
}

# ECS Application Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.name}-cluster"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory


  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "todo-app"
      image     = "${var.repository_url}:initial"
      essential = true

      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]

      environment = [
        {
          name  = "DB_SSL_CA"
          value = "/app/global-bundle.pem"
        },
        {
          name  = "PORT"
          value = tostring(var.container_port)
        },
        {
          name  = "DB_HOST"
          value = var.database_endpoint
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = var.database_name
        },
        {
          name  = "NODE_ENV"
          value = var.environment
        }
      ]

      # Retrieve database credentials from Secrets Manager
      secrets = [
        {
          name      = "RDS_MASTER_SECRET"
          valueFrom = var.database_secret_arn
        }

      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "todo"
        }
      }

      healthCheck = {
        command = [
          "CMD-SHELL",
          "node -e \"require('http').get('http://127.0.0.1:${var.container_port}/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))\""
        ]

        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.name}-task"
  }
}


resource "aws_appautoscaling_target" "ecs" {
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity

  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_cpu" {
  name        = "${var.name}-cpu-scaling"
  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}


# ECS Memory Auto Scaling
resource "aws_appautoscaling_policy" "ecs_memory" {
  name        = "${var.name}-memory-scaling"
  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}


# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = var.desired_count
  launch_type   = "FARGATE"

  platform_version = "LATEST"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "todo-app"
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_policy,
    aws_iam_role_policy.secrets_access
  ]

  tags = {
    Name = "${var.name}-service"
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

