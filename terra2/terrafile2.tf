provider "aws" { 
  region = "ap-south-1"
  //Creating a VPC, Public and Private Subnet, Internet Gateway, Route Table, Route Table Association, 
  //Security Group, EC2 Instances, Application Load Balancer, Target Group, and Listener using Terra
}

resource "aws_vpc" "vpc-ekt" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-ekt"
  }
}

resource "aws_subnet" "public-subnet-ekt" {
  vpc_id     = aws_vpc.vpc-ekt.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-ekt"
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
  subnet_id      = aws_subnet.public-subnet-ekt.id
  route_table_id = aws_route_table.public-route-table-ekt.id
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc-ekt.id

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

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.vpc-ekt.id

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
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_1" {
  ami           = "ami-00bb6a80f01f03502"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-ekt.id
  security_groups = [aws_security_group.ec2_sg.id]
  
}

resource "aws_instance" "ec2_2" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-ekt.id
  security_groups = [aws_security_group.ec2_sg.id]
  
}

resource "aws_lb" "alb" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public-subnet-ekt.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-ekt.id
}

resource "aws_lb_target_group_attachment" "ec2_1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2_1.id
}

resource "aws_lb_target_group_attachment" "ec2_2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2_2.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
