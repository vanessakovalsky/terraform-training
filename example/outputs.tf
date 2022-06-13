output "public_ip" {
    value = aws_instance.demo_instanceec2.public_ip
}

output "public_dns" {
  value = aws_instance.demo_instanceec2.public_dns
}