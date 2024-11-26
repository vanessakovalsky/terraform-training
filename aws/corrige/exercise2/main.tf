provider "aws" {
    region = var.AWS_REGION
}

resource "aws_instance" "my_ec2_instance"{
    ami = var.AWS_AMI
    instance_type = "t2.micro"
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
    name = "terraform-test-sg-vanessa"

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
    key_name = "key-vanessa"
    public_key = var.SSH_PUB_KEY
}

output "adresse_ip_instance" {
  value = aws_instance.my_ec2_instance.public_ip
}