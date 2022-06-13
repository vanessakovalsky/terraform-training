data "aws_ami" "ami_ubuntu"{
    owners = ["099720109477"]
    most_recent = true
    filter {
      name = "architecture"
      values = ["x86_64","i386"]
    }
}