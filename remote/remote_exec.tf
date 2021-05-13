provider "aws" {
  region = "us-east-1"
  access_key = "Your_access_key"
  secret_key = "Your_secret_key"
}


resource "aws_instance" "web" {
  ami           = "ami-096fda3c22c1c990a"
  instance_type = "t2.micro"
  key_name      = "test"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  tags = {
    Name = "remote-exec-provisioner"
  }

}

resource "null_resource" "copy_execute" {

    connection {
    type = "ssh"
    host = aws_instance.web.public_ip
    user = "ec2-user"
    private_key = file("test.pem")
    }


  provisioner "file" {
    source      = "httpd.sh"
    destination = "/tmp/httpd.sh"
  }

   provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/httpd.sh",
      "sh /tmp/httpd.sh",
    ]
  }

  depends_on = [ aws_instance.web ]

  }

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
}
