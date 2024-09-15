resource "aws_ecr_repository" "demo" {
  name = "${var.name}-basic"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = "ENHANCED" # inspector enabled on the org level

  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }
}
