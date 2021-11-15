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

# Create Subnet
resource "aws_subnet" "subnet0" {
  vpc_id     = aws_vpc.vpc0.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-tf"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc0.id

  tags = {
    Name = "gw-tf"
  }
}

# Create Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt-tf"
  }
}

# Create Subnet to Route Table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet0.id
  route_table_id = aws_route_table.rt.id
}

# Create Security Group
resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.vpc0.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-tf"
  }
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-04ad2567c9e3d7893"
  instance_type          = "t2.micro"
  key_name               = "terraform-checkpoint"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.SG.id]
  subnet_id              = aws_subnet.subnet0.id
  associate_public_ip_address = true
  availability_zone = "us-east-1a"
  user_data = file("install.sh")

  tags = {
    Name = "ec2-tf"
  }
}

# Create Output Variable
output "ec2-public-IPV4" {
  value = aws_instance.web.public_ip
}

