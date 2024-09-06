variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "root_pass" {
  type    = string
  default = "ansible"
}

variable "instance_name" {
  type    = string
  default = "server"
}

variable "ssh_private_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "/var/lib/jenkins/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJ0aLiohOZKlY2atZHQPT/vIU9wcCDjft3CR4G4sWSW"
}
