resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-ecs-family"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    # cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "${var.name}-container"
      image     = "${aws_ecr_repository.demo.repository_url}:latest"
      essential = true
      environment = [
        {
          "name" : "TZ",
          "value" : "Pacific/Auckland"
        },
        {
          "name" : "SQS_QUEUE_URL",
          "value" : aws_sqs_queue.s3_upload.url
        },
      ],
      cpu    = var.container_cpu
      memory = var.container_memory
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      mountPoints = []
      volumesFrom = []
      "linuxParameters" : {
        "initProcessEnabled" : true
      }
      logConfiguration = {
        "logDriver" = "awslogs"
        "options" = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_task.name,
          "awslogs-stream-prefix" = "ecs",
          "awslogs-region"        = var.region
        }
      }

    }
  ])
}

