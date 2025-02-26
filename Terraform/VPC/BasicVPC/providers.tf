provider "aws" {
  region = "us-east-1" # Change to your desired AWS region

  default_tags {
    tags = var.default_tags
  }
}