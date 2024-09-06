terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_key_pair" "example" {
  key_name   = "key02"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "prometheus_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = "key02"

  tags = {
    Name = "${terraform.workspace}_prometheus_server"
  }
  
  provisioner "local-exec" {
    command = "echo '${self.public_ip} prometheus_server_ip' >> inventory.ini"
  }
}

output "prometheus_server_ip" {
  value = aws_instance.prometheus_server.public_ip
}

resource "aws_instance" "app_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = "key02"

  tags = {
    Name = "${terraform.workspace}_app_server"
  }

  provisioner "local-exec" {
    command = "echo '${self.public_ip} app_server_public_ip' >> inventory.ini"
  }
}

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}

resource "aws_instance" "test_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = "key02"

  tags = {
    Name = "${terraform.workspace}_test_server"
  }

  provisioner "local-exec" {
    command = "echo '${self.public_ip} test_server_public_ip' >> inventory.ini"
  }
}

output "test_server_public_ip" {
  value = aws_instance.test_server.public_ip
}
