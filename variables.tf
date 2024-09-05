variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t2.micro"
}

variable "ssh_public_key" {
  description = "Path to the SSH public key"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtYQcWryY8vYWfHQHLhirjquhMRQ9Xf1ONf8+0ydL4p ubuntu@ip-172-31-11-64"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key"
  default     = "~/home/ubuntu/.ssh/id_rsa"
}
