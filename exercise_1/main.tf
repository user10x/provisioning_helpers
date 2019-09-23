resource "aws_instance" "ec2-terraform-instance" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  security_groups = [
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_outbound.name}"
  ]
  tags = {
    Name = "terrraform provisioned"
  }

  key_name        = "${aws_key_pair.ec2-key.key_name}"
}
