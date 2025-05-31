output "instance_private_ip" {
  value = "${aws_instance.ec2-bastion-host.private_ip}/32"
}

output "instance_public_ip" {
  value = "${aws_instance.ec2-bastion-host.public_ip}/32"
}

output "ssh_connect_ip" {
  value = aws_instance.ec2-bastion-host.public_ip
}