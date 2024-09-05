provider "aws" {
  region = "us-east-1"  # Update this to your desired region
}

resource "aws_key_pair" "example" {
  key_name   = "key02"
  public_key = file("~/.ssh/id_ed25519.pub")  # Path to your public key file
}

resource "aws_instance" "app_server" {
  ami           = "ami-0522ab6e1ddcc7055"  # Replace with your AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "AppServer"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")  # Path to your private key file
  }
}

resource "aws_instance" "test_server" {
  ami           = "ami-0522ab6e1ddcc7055"  # Replace with your AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "TestServer"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")  # Path to your private key file
  }
}

resource "aws_instance" "grafana_server" {
  ami           = "ami-0522ab6e1ddcc7055"  # Replace with your AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "GrafanaServer"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")  # Path to your private key file
  }
}
