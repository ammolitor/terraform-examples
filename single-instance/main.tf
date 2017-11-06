provider "aws" {
  region = "us-west-2"
}

resource "aws_eip" "webserver" {
  vpc = "true"
}

resource "aws_eip_association" "webserver" {
  instance_id   = "${aws_instance.webserver.id}"
  allocation_id = "${aws_eip.webserver.id}"
}

resource "aws_security_group" "webserver" {
  vpc_id = "vpc-5b3aa73d"
  name   = "webserver"
}

resource "aws_security_group_rule" "ingress_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webserver.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webserver.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.webserver.id}"
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "webserver" {
  ami                                  = "ami-e535c59d"
  instance_type                        = "t2.micro"
  availability_zone                    = "us-west-2a"
  ebs_optimized                        = "false"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "ammolitor-aws"
  monitoring                           = "false"
  vpc_security_group_ids               = ["${aws_security_group.webserver.id}"]
  subnet_id                            = "subnet-7b17d533"
  associate_public_ip_address          = "false"
  private_ip                           = "172.31.32.4"
  source_dest_check                    = "true"
  user_data                            = "${file("user-data.sh")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = "true"
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "gp2"
    volume_size           = "1"
    delete_on_termination = "true"
  }

  tags = {
    name       = "webserver"
    owner      = "Aaron Molitor"
    purpose    = "webserver"
    department = "testing"
  }

  volume_tags = {
    name       = "webserver"
    owner      = "Aaron Molitor"
    purpose    = "webserver"
    department = "testing"
  }
}
