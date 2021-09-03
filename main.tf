# Provider que o Terraform irá utilizar
provider "aws" {
  region = var.region
}


################################ Inicio da Criação de Grupos de Segurança #################################### 
# Security Group Http
resource "aws_security_group" "sg-http" {
  name = "ec2-elb-sg"

  # Liberar a porta 80 para acesso livre via Internet
  ingress = [
    {
      description      = "porta-80"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },

    {
      description      = "porta-8080"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }


  ]

  # Liberar todo o tráfego de saida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Security Group ssh
resource "aws_security_group" "sg-ssh" {
  name = "ec2-elb-sg-ssh"

  # Libera a porta 22 para acesso 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Security Group MySql
resource "aws_security_group" "sgmysql" {
  name = "sgmysql"

  ingress = [
    {
      description      = "sg-mysql-entrada"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "sg-mysql-saida"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "sg-mysql"
  }

}
################################ Inicio da criação de Grupos de Segurança #################################### 


################################ Inicio da Criação de Instancias EC2 #########################################
## EC2 Instance Apache1
resource "aws_instance" "servidor1" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["${aws_security_group.sg-http.name}", "${aws_security_group.sg-ssh.name}"]
  user_data       = file("install_apache_tomcat.sh")

  tags = {
    Name = "Servidor1"
  }
}

## EC2 Instance Apache2
resource "aws_instance" "servidor2" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["${aws_security_group.sg-http.name}", "${aws_security_group.sg-ssh.name}"]
  user_data       = file("install_apache_tomcat.sh")

  tags = {
    Name = "Servidor2"
  }
}

## EC2 Instance Jenkins
resource "aws_instance" "jenkins" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["${aws_security_group.sg-http.name}", "${aws_security_group.sg-ssh.name}"]
  user_data       = file("install_jenkins.sh")

  tags = {
    Name = "Jenkins"
  }
}

################################ Fim da Criação de Instancias EC2 ##############################################


################################ Ininio da Criação do Banco de Dados MySQL #####################################

#DB Intance MySql
resource "aws_db_instance" "mysql" {

  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = true

  vpc_security_group_ids = [aws_security_group.sgmysql.id]

  tags = {
    Name = "mysql"
  }
}

################################ Fim da Criação do Banco de Dados MySQL #####################################


################################ Inicio da Configuração do Load Balance ####################################

## Configuração do Load Balance
resource "aws_elb" "load-balance" {
  name               = "ec2-elb"
  instances          = ["${aws_instance.servidor1.id}", "${aws_instance.servidor2.id}"]
  availability_zones = var.availability_zones

  ## Listener Ports do Load Balance
  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  ## Health Check Configs 
  ## Será um healthcheck simples HTTP
  health_check {
    target              = "HTTP:80/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 10
  }

  tags = {
    Name = "ec2-elb"
  }
}

################################ Fim da Configuração do Load Balance ####################################



