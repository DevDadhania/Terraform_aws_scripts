provider "aws" {
  region = "ap-south-1"
  //Createing a VPC, Subnets, Internet Gateway, Route Table, Route Table Association, Security Group, EC2 Instances, RDS Instance, S3 Bucket
  //One EC2 instance in public subnet and one EC2, RDS in private subnet
}

resource "aws_vpc" "vpc-ekt" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc-ekt"
  }
}

resource "aws_subnet" "publick-subnet-ekt" {
  vpc_id     = aws_vpc.vpc-ekt.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "publick-subnet-ekt"
  }
}

resource "aws_subnet" "private-subnet-ekt" {
  vpc_id     = aws_vpc.vpc-ekt.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-ekt"
  }
}

resource "aws_internet_gateway" "Igw-ekt" {
  vpc_id = aws_vpc.vpc-ekt.id

  tags = {
    Name = "Igw-ekt"
  }
}

resource "aws_route_table" "public-route-table-ekt" {
  vpc_id = aws_vpc.vpc-ekt.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Igw-ekt.id
    }

    tags = {
    Name = "public-route-table-ekt"
  }

}

resource "aws_route_table_association" "public-route-table-association-ekt" {
  subnet_id      = aws_subnet.publick-subnet-ekt.id
  route_table_id = aws_route_table.public-route-table-ekt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc-ekt.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

   tags = {
    Name = "allow_all"
  }

}

resource "aws_instance" "ec2-public-ekt" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.publick-subnet-ekt.id
  key_name      = "ekt-key"
  security_groups = [aws_security_group.allow_all.name]

  tags = {
    Name = "ec2-public-ekt"
  }
}

resource "aws_instance" "ec2-private-ekt" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet-ekt.id
  key_name      = "ekt-key"
  security_groups = [aws_security_group.allow_all.name]

  tags = {
    Name = "ec2-private-ekt"
  }
}

resource "aws_db_instance" "postgres-ekt" {
  identifier        = "postgres-ekt"
  engine            = "postgres"
  engine_version    = "13.3"  
  instance_class    = "db.t3.micro"  
  allocated_storage = 1
  db_name           = "mydatabase"  
  username          = "mydbuser"  
  password          = "mydbpassword"  
  port              = 5432
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  multi_az          = false
  storage_type      = "gp2"  
  backup_retention_period = 7  

  tags = {
    Name = "postgres-ekt"
  }

  publicly_accessible = false
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my_db_subnet_group"
  subnet_ids = [aws_subnet.private-subnet-ekt.id]
  tags = {
    Name = "MyDBSubnetGroup"
  }
}

resource "aws_s3_bucket" "s3-ekt" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "s3-ekt"
  }
}