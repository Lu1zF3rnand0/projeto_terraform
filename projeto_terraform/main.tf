# Provider que o Terraform irá utilizar
provider "aws" {
  region = "${var.region}" 
}

# Security Group
resource "aws_security_group" "http" {
  name = "ec2-elb-sg"
  
  # Liberar a porta 80 para acesso livre via Internet
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Liberar todo o tráfego de saida
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ssh" {
  name = "ec2-elb-sg-ssh"
  
  # Liberar a porta 22 para acesso 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}


## EC2 Instance 1
resource "aws_instance" "servidor1" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "terraform-key"
  security_groups = ["${aws_security_group.http.name}", "${aws_security_group.ssh.name}"]
  user_data = file("install_tools.sh")

  tags = {
    Name = "Servidor1"
  }
}

## EC2 Instance 2
resource "aws_instance" "servidor2" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "terraform-key"
  security_groups = ["${aws_security_group.http.name}", "${aws_security_group.ssh.name}"]
  user_data = file("install_tools.sh")

  tags = {
    Name = "Servidor2"
  }
}

## Configuração do Load Balance
resource "aws_elb" "default" {
  name = "ec2-elb"
  instances = ["${aws_instance.servidor1.id}", "${aws_instance.servidor2.id}"]
  availability_zones = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
  
  ## Listener Ports do Load Balance
  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }
  
  ## Health Check Configs 
  ## Será um healthcheck simples HTTP
  health_check {
    target = "HTTP:80/"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 30
    timeout = 5
  }

  tags = {
    Name = "ec2-elb"
  }
}