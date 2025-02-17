
# Store the RapidAPI key securely in AWS Systems Manager Parameter Store

resource "aws_ssm_parameter" "rapidapi_key" {
  name        = "/myproject/rapidapi_key"
  type        = "SecureString"
  value       = var.rapidapi_key
  description = "API key for external service"

}
