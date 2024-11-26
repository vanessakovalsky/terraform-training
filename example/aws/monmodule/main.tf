resource "aws_key_pair" "maclessh" {
    key_name = var.KEY_NAME
    public_key = var.SSH_PUB_KEY
}