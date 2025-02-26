# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.default_tags, { Name = "my-vpc" })
}

# Create an Internet Gateway (IGW)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.default_tags, { Name = "my-igw" })
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags              = merge(var.default_tags, { Name = "public-subnet-1" })
}


# Create a custom route table for the VPC
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.default_tags, { Name = "public-route-table" })
}

# Associate the public subnets with the route table
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

