variable "aws_region" {
  type        = string
  description = "AWS region for the EC2 instance"
  default     = "ap-south-1"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "Key pair name for the EC2 instance"
  default     = "key02"
}

variable "ssh_private_key" {
  type        = string
  description = "Path to the SSH private key for EC2 instance access"
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for EC2 instance access"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for launching the EC2 instance"
  default     = "ami-0522ab6e1ddcc7055"
}
