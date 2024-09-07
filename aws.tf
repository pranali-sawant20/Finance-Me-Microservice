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

# AWS Key Pair
resource "aws_key_pair" "example" {
  key_name   = var.key_name
  public_key = file(var.ssh_public_key)
}

# AWS EC2 Instance
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.example.key_name

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
      "sudo apt-get install -y python3",
      "mkdir -p /home/ubuntu/.ssh",
      "echo '${var.ssh_public_key}' >> /home/ubuntu/.ssh/authorized_keys",
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
      ansible-playbook -u ubuntu -i inventory.ini -e 'ansible_python_interpreter=/usr/bin/python3' ansible-playbook.yml
    EOF
  }
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.server.public_ip
}
