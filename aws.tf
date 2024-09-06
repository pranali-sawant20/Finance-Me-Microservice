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

# Key Pair
resource "aws_key_pair" "example" {
  key_name   = "demo1"
  public_key = var.ssh_public_key
}

# Application Server
resource "aws_instance" "app_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = "key01"

  tags = {
    Name = "AppServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz",
      "tar -zxvf node_exporter-1.8.2.linux-amd64.tar.gz",
      "sudo cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/",
      "sudo useradd -rs /bin/false node_exporter",
      "sudo tee /etc/systemd/system/node_exporter.service <<EOF\n[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=node_exporter\nExecStart=/usr/local/bin/node_exporter\n\n[Install]\nWantedBy=multi-user.target\nEOF",
      "sudo systemctl daemon-reload",
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
      "wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz",
      "tar -zxvf node_exporter-1.8.2.linux-amd64.tar.gz",
      "sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/",
      "sudo useradd -rs /bin/false node_exporter",
      "sudo tee /etc/systemd/system/node_exporter.service <<EOF\n[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=node_exporter\nExecStart=/usr/local/bin/node_exporter\n\n[Install]\nWantedBy=multi-user.target\nEOF",
      "sudo systemctl daemon-reload",
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

# Prometheus Server
resource "aws_instance" "prometheus_server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "PrometheusServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y prometheus",
      "sudo systemctl start prometheus",
      "sudo systemctl enable prometheus",
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

output "prometheus_server_ip" {
  value = aws_instance.prometheus_server.public_ip
}
