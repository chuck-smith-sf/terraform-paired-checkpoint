terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc0" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-terraform"
  }
}

resource "aws_subnet" "subnet0" {
  vpc_id     = aws_vpc.vpc0.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "sn-tf"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc0.id

  tags = {
    Name = "gw-tf"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc0.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt-tf"
  }
}

# variable "common_cidr_block" {
#   type    = string
#   default = "10.0.30.0/24"
# }


# resource "aws_subnet" "subnet0" {
#   vpc_id     = aws_vpc.vpc0.id
#   cidr_block = var.common_cidr_block

#   tags = {
#     Name = "example-subnet"
#   }
# }

# output "subnet0_id" {
#   value = aws_subnet.subnet0.vpc_id
# }

# resource "aws_subnet" "subnet0" {
#   vpc_id     = aws_vpc.vpc0.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "example-subnet"
#   }
# }
