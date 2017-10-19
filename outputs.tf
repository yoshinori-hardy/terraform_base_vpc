
output "NAT Gateway EIP" {
  value = "${aws_eip.nat.public_ip}"
}

output "VPN EIP" {
  value = "${aws_eip.vpn.public_ip}"
}

output "IAM App Server Role" {
  value = "${aws_iam_instance_profile.app_server_profile.id}"
}

output "App Server Subnet AZ-A" {
  value = "${aws_subnet.application-a.id}"
}

output "App Server Subnet AZ-B" {
  value = "${aws_subnet.application-b.id}"
}

output "NAT Gateway ID" {
  value = "${aws_nat_gateway.natgw.id}"
}
