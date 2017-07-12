provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "tf-demo" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "tf-demo" {
  vpc_id = "${aws_vpc.tf_demo.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.tf-demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.tf_demo.id}"
}

resource "aws_subnet" "tf-demo" {
  vpc_id                  = "${aws_vpc.tf-demo.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "tf-elb-sg" {
  name        = "Terraform SG for ELB"
  description = "ELB Security Group for terraform"
  vpc_id      = "${aws_vpc.tf_demo.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tf-vpc-sg" {
  name        = "Terraform SG for VPC"
  description = "VPC Security Group for terraform"
  vpc_id      = "${aws_vpc.tf_demo.id}"

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "tf-demo" {
  name = "tf-demo"

  subnets         = ["${aws_subnet.tf-demo.id}"]
  security_groups = ["${aws_security_group.tf-elb-sg.id}"]
  instances       = ["${aws_instance.tf-demo.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "tf-demo" {
  instance_type = "t2.micro"
  ami = "ami-a4c7edb2"

  # Our Security group to allow HTTP access
  vpc_security_group_ids = ["${aws_security_group.tf-vpc-sg.id}"]

  subnet_id = "${aws_subnet.tf-demo.id}"
  user_data = "${file("userdata.sh")}"
}
