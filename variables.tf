variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_private_key" {
  type    = string
  default = "/var/lib/jenkins/.ssh/id_ed25519"
}

variable "ssh_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5J5aJ3iY0+/qP4lLgnT0Lkcv0jEAtm+oYDMpLRAm3J"
}
