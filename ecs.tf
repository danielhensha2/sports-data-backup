# ECS cluster definition
resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster
}

# CloudWatch log group for ECS logs with 7 day retention
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/sports-backup"
  retention_in_days = 7
}

# ECS task definition for Fargate launch type
resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # IAM roles for task execution and task role
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  # Dependencies required before task definition can be created
  depends_on = [aws_ecr_repository.this, aws_iam_role.ecs_task_execution_role, docker_registry_image.image]

  # Container definition with environment variables and logging configuration
  container_definitions = templatefile("${path.module}/container_definitions.tpl", {
    container_name             = var.container_name
    image                      = "${aws_ecr_repository.this.repository_url}:latest"
    log_group_name             = aws_cloudwatch_log_group.ecs_log_group.name
    rapidapi_ssm_parameter_arn = aws_ssm_parameter.rapidapi_key.arn
    mediaconvert_role_arn      = aws_iam_role.mediaconvert_role.arn
    region                     = var.aws_region
    api_url                    = var.api_url
    rapidapi_host              = var.rapidapi_host
    league_name                = var.league_name
    date                       = var.date
    limit                      = var.limit
    input_key                  = var.input_key
    output_key                 = var.output_key
    aws_region                 = var.aws_region
    s3_bucket_name             = var.s3_bucket_name
    mediaconvert_endpoint      = var.mediaconvert_endpoint
    retry_count                = var.retry_count
    retry_delay                = var.retry_delay
    wait_time_between_scripts  = var.wait_time_between_scripts
    dynamodb_table             = var.dynamodb_table
  })

}

# ECS service running on Fargate
resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Network configuration for the Fargate tasks
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = true
  }

  # Use ECS deployment controller
  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name = "${var.project_name}-service"
  }
}

