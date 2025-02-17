
# DynamoDB table for storing highlights data
resource "aws_dynamodb_table" "highlights_table" {
  # Table name from variables
  name         = var.dynamodb_table
  # Use on-demand pricing model
  billing_mode = "PAY_PER_REQUEST" # On-demand capacity
  # Primary key configuration
  hash_key     = "id"

  # Define primary key attribute
  attribute {
    name = "id"
    type = "S"  # String type
  }

  # Resource tagging
  tags = {
    Name = "${var.project_name}-highlights-table"

  }
}
