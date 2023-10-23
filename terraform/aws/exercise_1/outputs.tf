output "server-ip" {
  value = "${aws_instance.ec2-terraform-instance.public_ip}"
}
