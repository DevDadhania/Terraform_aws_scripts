provider "aws" {
    region = "ap-south-1"
    //Base script for creating VPC, Subnet, Internet Gateway, Route Table, Route Table Association, Security Group, DB Subnet Group
  
}

resource "aws_vpc" "VPC-NAME" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "VPC-NAME"
  }
}

resource "aws_subnet" "publick-subnet-name" {
  vpc_id     = aws_vpc.VPC-NAME.id
  cidr_block = "10.0.0.0/17"
  map_public_ip_on_launch = true

  tags = {
    Name = "publick-subnet-name"
  }
}

resource "aws_subnet" "private-subnet-name" {
  vpc_id     = aws_vpc.VPC-NAME.id
  cidr_block = "10.0.128.0/17"

  tags = {
    Name = "private-subnet-name"
  }
}

resource "aws_internet_gateway" "Igw-name" {
  vpc_id = aws_vpc.VPC-NAME.id

  tags = {
    Name = "Igw-name"
  }
}

resource "aws_route_table" "public-route-table-name" {
  vpc_id = aws_vpc.VPC-NAME.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Igw-name.id
    }

    tags = {    
    Name = "public-route-table-name"
    }   
}

resource "aws_route_table_association" "public-route-table-association-name" {
  subnet_id      = aws_subnet.publick-subnet-name.id
  route_table_id = aws_route_table.public-route-table-name.id
}

resource "aws_security_group" "allow-port"{ 
  name        = "allow-port"
  vpc_id = aws_vpc.VPC-NAME.id

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db-subnet-group-name" {
  name       = "db-subnet-group-name"
  subnet_ids = [aws_subnet.private-subnet-name.id]
  tags = {
    Name = "db-subnet-group-name"
  }
}

