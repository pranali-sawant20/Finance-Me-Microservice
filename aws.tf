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

variable "instance_type" {
  default = "t2.micro"
}

# Update SSH Key variables if using id_rsa instead of id_ed25519
variable "ssh_public_key" {
  # Adjusted to use id_rsa.pub instead of id_ed25519.pub
  default = "/home/ubuntu/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  # Adjusted to use id_rsa instead of id_ed25519
  default = "/home/ubuntu/.ssh/id_rsa"
}

# Key Pair
resource "aws_key_pair" "example" {
  key_name   = "key02"
  public_key = file(var.ssh_public_key)
}

# Application Server
resource "aws_instance" "app_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "AppServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y prometheus node_exporter",
      "sudo systemctl start node_exporter",
      "sudo systemctl enable node_exporter",
      "sudo ufw allow 9100/tcp",
      "sudo ufw allow 9090/tcp"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
  }
}

# Test Server
resource "aws_instance" "test_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "TestServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y prometheus node_exporter",
      "sudo systemctl start node_exporter",
      "sudo systemctl enable node_exporter",
      "sudo ufw allow 9100/tcp",
      "sudo ufw allow 9090/tcp"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
  }
}

# Grafana Server
resource "aws_instance" "grafana_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "GrafanaServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y grafana",
      "sudo systemctl start grafana-server",
      "sudo systemctl enable grafana-server",
      "sudo ufw allow 3000/tcp"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
  }
}

# Outputs for Public IPs
output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "test_server_public_ip" {
  value = aws_instance.test_server.public_ip
}

output "grafana_server_public_ip" {
  value = aws_instance.grafana_server.public_ip
}