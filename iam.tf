
# Get the current AWS account identity
data "aws_caller_identity" "current" {}

# Define the trust relationship for MediaConvert service
data "aws_iam_policy_document" "mediaconvert_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["mediaconvert.amazonaws.com"]
    }
  }
}

# Create the IAM role for MediaConvert with the trust policy
resource "aws_iam_role" "mediaconvert_role" {
  name               = "${var.project_name}-mediaconvert-role"
  assume_role_policy = data.aws_iam_policy_document.mediaconvert_trust.json
}

# Define permissions for MediaConvert to access S3 and CloudWatch Logs
data "aws_iam_policy_document" "mediaconvert_policy_doc" {
  statement {
    # Allow S3 operations for input/output files
    actions = ["s3:GetObject", "s3:PutObject", "s3:CreateBucket", "s3:ListBucket"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
  statement {
    # Allow writing logs to CloudWatch
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}/*"]
  }
}

# Create IAM policy from the policy document
resource "aws_iam_policy" "mediaconvert_policy" {
  name   = "${var.project_name}-mediaconvert-s3-logs"
  policy = data.aws_iam_policy_document.mediaconvert_policy_doc.json
}

# Attach the custom policy to MediaConvert role
resource "aws_iam_role_policy_attachment" "mediaconvert_attach" {
  role       = aws_iam_role.mediaconvert_role.name
  policy_arn = aws_iam_policy.mediaconvert_policy.arn
}

# Attach AWS managed MediaConvert policy for full access
resource "aws_iam_role_policy_attachment" "MediaconvertPolicyAttachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaConvertFullAccess"
  role       = aws_iam_role.mediaconvert_role.name
}

# Define trust relationship for ECS tasks
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create ECS task execution role with trust policy
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

# Attach AWS managed ECS task execution policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Define custom permissions for ECS tasks
data "aws_iam_policy_document" "ecs_custom_doc" {
  statement {
    # Allow S3 operations
    actions = ["s3:GetObject", "s3:PutObject", "s3:CreateBucket", "s3:ListBucket"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
  statement {
    # Allow DynamoDB operations
    actions = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:Query", "dynamodb:Scan"]
    effect  = "Allow"
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table}"
    ]
  }
  statement {
    # Allow access to SSM parameters
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/myproject/rapidapi_key"]
  }
  statement {
    # Allow ECR image pulling
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    effect    = "Allow"
    resources = ["arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.this.name}"]
  }

  statement {
    # Allow CloudWatch Logs operations
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}/*"]
  }
}

# Create custom IAM policy for ECS tasks
resource "aws_iam_policy" "ecs_custom_policy" {
  name   = "${var.project_name}-ecs-custom-policy"
  policy = data.aws_iam_policy_document.ecs_custom_doc.json
}

# Attach custom policy to ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_custom_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_custom_policy.arn
}

# Attach MediaConvert full access policy to ECS role
resource "aws_iam_role_policy_attachment" "Mediaconvert_ecs_PolicyAttachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaConvertFullAccess"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# Define trust relationship for EventBridge Scheduler
data "aws_iam_policy_document" "scheduler_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

# Create IAM role for EventBridge Scheduler
resource "aws_iam_role" "scheduler_task_role" {
  name               = "${var.project_name}-scheduler-task-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_trust.json
}

# Define permissions for EventBridge Scheduler
data "aws_iam_policy_document" "scheduler_custom_doc" {
  statement {
    # Allow running ECS tasks
    actions = ["ecs:RunTask"]
    effect  = "Allow"
    resources = [
      aws_ecs_task_definition.this.arn
    ]
  }
  statement {
    # Allow passing IAM roles
    actions = ["iam:PassRole"]
    effect  = "Allow"
    resources = [
      aws_iam_role.ecs_task_execution_role.arn,
      aws_iam_role.mediaconvert_role.arn
    ]
  }
}

# Create IAM policy for EventBridge Scheduler
resource "aws_iam_policy" "scheduler_policy" {
  name   = "${var.project_name}-scheduler-policy"
  policy = data.aws_iam_policy_document.scheduler_custom_doc.json
}

# Attach scheduler policy to scheduler role
resource "aws_iam_role_policy_attachment" "scheduler_policy_attachment" {
  role       = aws_iam_role.scheduler_task_role.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}


