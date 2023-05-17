provider "aws" {
    region = var.AWS_REGION
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY 
}

resource "aws_instance" "my_ec2_instance"{
    ami = data.aws_ami.ubuntu-ami.id
    instance_type = tolist(data.aws_ec2_instance_types.ami_instance.instance_types)[0]
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name = aws_key_pair.maclessh.key_name
    user_data = <<-EOF
		#!/bin/bash
        sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		sudo echo "<h1>Hello students</h1>" > /var/www/html/index.html
	EOF
    
    tags = {
        Name = "terraform correction vanessa"
    }
}

resource "aws_security_group" "instance_sg" {
    name = "terraform-test-sg-vanessa4"

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_key_pair" "maclessh" {
    key_name = "key-vanessa4"
    public_key = var.SSH_PUB_KEY
}

output "adresse_ip_instance" {
  value = aws_instance.my_ec2_instance.public_ip
}

data "aws_ami" "ubuntu-ami"{
    owners = ["099720109477"]
    most_recent = true
    
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"]
    }
}

data "aws_ec2_instance_types" "ami_instance" {
    filter {
      name = "processor-info.supported-architecture"
      values = [data.aws_ami.ubuntu-ami.architecture]
    }
}


module "website_s3_bucket" {
    source = "./modules/aws-s3-static-website-bucket"
    bucket_name = "vanessa-terraform-module"
}