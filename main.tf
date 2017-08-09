resource "aws_key_pair" "deployment" {
  key_name   = "deployment-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUXzy0vVwSEJq/Dk5ntdoSgAV5gNtYUMz5Rmkv793NN3Hw+FZk1iTLxrKvTkwNmAB9+NVHa0ORwru0PCDOIkC0ua0244r2CODSE/yjOMslzdS+y17x0+n7HM9OU8663o+A/e/eL4r22jn62sFzRwPPfZADl04m31FEcYyjG7G6suOq84SU+pno7SNUnKSlqFRXIEsfwRSy0t4pqgdArHTdsa+NmORvkmS25QgRGmGY0Hs3gx+9+axuNjL8V9Uke+mE+6aeFVEQWlmq9e+HseBPYnujlPqOm4ro4dzk5bF0VGtjTWhc5rVBOyXXPivfPjA3LYHgKKHMEvy/qqKCoHQD deployment-key"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "demo" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name   = "Public route table"
    source = "terraform"
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.public_route.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = "${aws_subnet.demo.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow  traffic for http and ssh"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "demo" {
  ami           = "ami-6df1e514"          #Amazon Linux AMI in us-west-2
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.demo.id}"

  vpc_security_group_ids = ["${aws_security_group.demo-sg.id}"]

  associate_public_ip_address = true

  tags {
    source = "terraform"
    Name   = "demo-aws"
  }

  key_name = "deployment-key"

  # ebs_block_device {
  #   device_name = "/dev/sdg"
  #   volume_type = "standard"
  #   volume_size = 1
  # }

  user_data = "${file("data/webserver.sh")}"
}

resource "aws_eip" "demo" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.demo.id}"
  allocation_id = "${aws_eip.demo.id}"
}

resource "aws_ebs_volume" "demo" {
  availability_zone = "us-west-2a"
  size              = 1

  tags {
    Name = "demo"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdg"
  volume_id   = "${aws_ebs_volume.demo.id}"
  instance_id = "${aws_instance.demo.id}"
}
