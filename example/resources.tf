resource "aws_instance" "demo_instanceec2"{
    ami = data.aws_ami.ami_ubuntu.id
    instance_type = var.instance-type
    tags = {
        Name = "terraform example vanessa"
    }
}
