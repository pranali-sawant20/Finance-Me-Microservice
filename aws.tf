terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create or use an existing key pair
resource "aws_key_pair" "example" {
  count      = var.key_pair_exists ? 0 : 1
  key_name   = var.key_name
  public_key = file(var.ssh_public_key)

  lifecycle {
    prevent_destroy = true
  }
}

# AWS EC2 Instance
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name        = "${terraform.workspace}_server"
    Environment = terraform.workspace
    Project     = "FinanceMe"
  }

  # Remote execution
  provisioner "remote-exec" {
    inline = [
      "echo 'Provisioning started on ${self.public_ip}'",
      "sudo apt-get update -y",
      "mkdir -p /home/ubuntu/.ssh",
      "echo '${file(var.ssh_public_key)}' >> /home/ubuntu/.ssh/authorized_keys",
      "chmod 600 /home/ubuntu/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh",
      "cat /etc/os-release"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
    timeout     = "5m"
  }

  # Generate inventory for Ansible
  provisioner "local-exec" {
    command = <<EOF
      echo "${self.public_ip} ansible_user=ubuntu ansible_private_key_file=${var.ssh_private_key}" > inventory.ini
    EOF
  }

  # Run Ansible playbook
  provisioner "local-exec" {
    command = <<EOF
      ansible-playbook -u ubuntu -i inventory.ini -e 'prometheus_ip=${self.public_ip}' -e 'ansible_python_interpreter=/usr/bin/python3' ansible-playbook.yml
    EOF
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.server.public_ip
}
