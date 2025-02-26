ami_id           = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI ID (e.g., Amazon Linux 2)
instance_type    = "t2.micro"              # Instance type
key_pair_name    = "my-key-pair"          # Replace with your existing key pair name
subnet_id = "subnet-12345678" # Replace with the actual subnet ID
default_tags     = {
  Environment = "dev"
  Project     = "ec2-example"
  Owner       = "DevOps Team"
}
