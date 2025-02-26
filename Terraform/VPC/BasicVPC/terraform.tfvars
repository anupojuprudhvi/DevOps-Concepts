vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24"
]

availability_zones = [
  "us-east-1a"
]

default_tags = {
  Environment = "dev"
  Project     = "my-project"
  Owner       = "DevOps Team"
}