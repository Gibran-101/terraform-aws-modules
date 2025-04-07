data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#pulls public IP dynamically whenever instance is created.
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
  request_headers = {
    Accept = "text/plain"
  }
}


