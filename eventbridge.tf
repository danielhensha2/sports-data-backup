# Create EventBridge Scheduler Schedule
resource "aws_scheduler_schedule" "ecs_task" {
  name                         = "${var.project_name}-scheduler"
  group_name                   = "default"
  description                  = "One-time ECS task trigger"
  schedule_expression          = "at(2025-02-12T13:00:00)"  
  schedule_expression_timezone = "UTC+01:00"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_ecs_cluster.this.arn
    role_arn = aws_iam_role.scheduler_task_role.arn

    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.this.arn
      task_count          = 1
      launch_type         = "FARGATE"

      network_configuration {
        subnets          = [aws_subnet.public_subnet.id]
        security_groups  = [aws_security_group.ecs_task.id]
        assign_public_ip = true
      }
    }
  }
}
