
# ECS CPU alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.name}-ecs-cpu-high"
  alarm_description   = "ECS service CPU utilisation is above 80%"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 300
  statistic          = "Average"
  threshold          = 80

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  treat_missing_data = "notBreaching"
}

# ECS memory alarm
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.name}-ecs-memory-high"
  alarm_description   = "ECS service memory utilisation is above 80%"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "MemoryUtilization"
  namespace          = "AWS/ECS"
  period             = 300
  statistic          = "Average"
  threshold          = 80

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  treat_missing_data = "notBreaching"
}

# RDS CPU alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.name}-rds-cpu-high"
  alarm_description   = "RDS CPU utilisation is above 80%"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"
  period             = 300
  statistic          = "Average"
  threshold          = 80

  dimensions = {
    DBInstanceIdentifier = var.database_instance_identifier
  }

  treat_missing_data = "notBreaching"
}

# RDS free storage alarm: less than 2 GB
resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.name}-rds-storage-low"
  alarm_description   = "RDS free storage is below 2 GB"
  comparison_operator = "LessThanThreshold"

  evaluation_periods = 2
  metric_name        = "FreeStorageSpace"
  namespace          = "AWS/RDS"
  period             = 300
  statistic          = "Average"
  threshold          = 2147483648

  dimensions = {
    DBInstanceIdentifier = var.database_instance_identifier
  }

  treat_missing_data = "notBreaching"
}

# ALB HTTP 5xx alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx_high" {
  alarm_name          = "${var.name}-alb-5xx-high"
  alarm_description   = "ALB is returning more than 10 HTTP 5xx errors in 5 minutes"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 1
  metric_name        = "HTTPCode_ELB_5XX_Count"
  namespace          = "AWS/ApplicationELB"
  period             = 300
  statistic          = "Sum"
  threshold          = 10

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
  }

  treat_missing_data = "notBreaching"
}

# Central monitoring dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "ECS CPU Utilisation"
          region = var.aws_region
          period = 300
          stat   = "Average"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              var.cluster_name,
              "ServiceName",
              var.service_name
            ]
          ]
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "ECS Memory Utilisation"
          region = var.aws_region
          period = 300
          stat   = "Average"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              var.cluster_name,
              "ServiceName",
              var.service_name
            ]
          ]
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "RDS CPU Utilisation"
          region = var.aws_region
          period = 300
          stat   = "Average"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              var.database_instance_identifier
            ]
          ]
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "RDS Database Connections"
          region = var.aws_region
          period = 300
          stat   = "Average"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              var.database_instance_identifier
            ]
          ]
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "RDS Free Storage"
          region = var.aws_region
          period = 300
          stat   = "Average"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              var.database_instance_identifier
            ]
          ]
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "ALB HTTP 5xx Errors"
          region = var.aws_region
          period = 300
          stat   = "Sum"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              var.load_balancer_arn_suffix
            ],
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer",
              var.load_balancer_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6

        properties = {
          title  = "ALB Target Response Time"
          region = var.aws_region
          period = 300
          stat   = "Average"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.load_balancer_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix
            ]
          ]
        }
      }
    ]
  })
}
