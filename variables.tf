# AWS Region for the EC2 instance
variable "aws_region" {
  type        = string
  description = "AWS region for the EC2 instance"
  default     = "ap-south-1"
}

# EC2 instance type
variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

# Key pair name for the EC2 instance
variable "key_name" {
  type        = string
  description = "Key pair name for the EC2 instance"
  default     = "key02"
}

# SSH private key for EC2 instance access
variable "ssh_private_key" {
  type        = string
  description = "Path to the SSH private key for EC2 instance access"
  default     = "~/.ssh/id_ed25519"
}

# SSH public key for EC2 instance access
variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for EC2 instance access"
  default     = "~/.ssh/id_ed25519.pub"
}

# AMI ID for launching the EC2 instance
variable "ami_id" {
  type        = string
  description = "AMI ID for launching the EC2 instance"
  default     = "ami-0522ab6e1ddcc7055"
}

# Path to the Ansible playbook
variable "ansible_playbook_path" {
  type        = string
  description = "Path to the Ansible playbook to be executed"
  default     = "./ansible-playbook.yml"
}

# Name of the Terraform workspace (test or production)
variable "workspace" {
  type        = string
  description = "The workspace name, used for different environments (test, production)"
  default     = "test"
}

# Default user for the EC2 instance
variable "ec2_user" {
  type        = string
  description = "Username to use when connecting to EC2 instances"
  default     = "ubuntu"
}
