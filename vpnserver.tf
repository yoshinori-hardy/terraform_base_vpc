#Set up VPN server
# Create an EIP to attach to VPN Server
resource "aws_eip" "vpn" {
  instance = "${aws_instance.vpn_server.id}"
  vpc      = true
  depends_on = ["aws_instance.vpn_server"]
  provisioner "file" {
    source = "provisioning/libreswansetup.sh"
    destination = "/tmp/libreswansetup.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      timeout     = "5m"
      host        = "${aws_eip.vpn.public_ip}"
      private_key = "${file("~/.ssh/********")}"
      }
  }
  provisioner "remote-exec" {
    inline = [
    "chmod +x /tmp/libreswansetup.sh",
    "sudo /tmp/libreswansetup.sh > /tmp/vpn_setup.log"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      timeout     = "2m"
      host        = "${aws_eip.vpn.public_ip}"
      private_key = "${file("~/.ssh/********")}"
    }
  }
}

resource "aws_instance" "vpn_server" {
  ami                         = "${var.aws_ami}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.gateway-b.id}"
  key_name                    = "${var.key_name}"
  count                       = 1
  vpc_security_group_ids      = ["${aws_security_group.vpn-sg.id}","${aws_security_group.internet-out-sg.id}"]
  tags {
      Name = "vpn_server"
      environment = "${var.env}"
      }
  lifecycle {
    create_before_destroy = true
    }
}
