# S3 bucket to store highlights
resource "aws_s3_bucket" "highlights" {
  bucket        = var.s3_bucket_name
  force_destroy = true

}
