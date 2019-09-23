resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = "${file("ec2-key.pub")}"
}
