##--------ECS---------##

resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name = "${var.name}-ecs-cluster"

  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_task" {
  name = "${var.name}-ecs-task"

  retention_in_days = 7
}
