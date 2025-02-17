
# Create ECR Repository
resource "aws_ecr_repository" "this" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

}

# Create Docker image
resource "docker_image" "image" {
  name = "${aws_ecr_repository.this.repository_url}:latest"
  build {
    context    = "${path.root}/app" 
    dockerfile = "Dockerfile"
  }
}
# Push docker image to ECR repo
resource "docker_registry_image" "image" {
  name = docker_image.image.name

}