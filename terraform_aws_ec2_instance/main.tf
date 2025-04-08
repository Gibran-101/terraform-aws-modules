# Generate TLS Private Key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create Local Private Key File
resource "local_file" "private_key" {
  filename        = "${path.module}/.ssh/ssh_key.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"

  lifecycle {
    replace_triggered_by = [
      tls_private_key.ssh_key.private_key_pem
    ]
  }
}



# Generate Unique Suffix
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# AWS Key Pair
resource "aws_key_pair" "deployed_key" {
  key_name   = "ssh-key-${random_string.suffix.result}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

locals {
  is_windows = var.is_windows

  common_tags = {
    Environment = "dev"
    Project     = "ec2-webserver"
    Owner       = "Gibran"
    ManagedBy   = "Terraform"
  }

  cidr = ["${trimspace(data.http.my_ip.response_body)}/32"]
}


# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployed_key.key_name

  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true
  depends_on                  = [aws_key_pair.deployed_key]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Web Server-${random_string.suffix.result}"
    }
  )
}

resource "null_resource" "fix_windows_key_perms" {
  count = local.is_windows ? 1 : 0

  depends_on = [local_file.private_key] # Ensure the file exists

  provisioner "local-exec" {
    command = <<EOT
      icacls "${path.module}\\.ssh\\ssh_key.pem" /inheritance:r
      icacls "${path.module}\\.ssh\\ssh_key.pem" /grant:r "$($env:USERNAME):R"
      icacls "${path.module}\\.ssh\\ssh_key.pem" /remove "Users"
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}


resource "null_resource" "fix_linux_key_perms" {
  count = local.is_windows ? 0 : 1

  provisioner "local-exec" {
    command     = "chmod 400 ssh_key.pem"
    interpreter = ["bash", "-c"]
  }
}


# VPC Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1" # use latest stable

  name = "my-dynamic-vpc"
  cidr = "10.0.0.0/16"

  azs            = [var.availability_zone]
  public_subnets = ["10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "VPC-${random_string.suffix.result}"
    }
  )

}


# Security Group
locals {
  ingress_rules = [
    {
      description = "SSH from my IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]
    },
    {
      description = "HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access-${random_string.suffix.result}"
  description = "Allow SSH, HTTP, and HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "SSH Access Security Group-${random_string.suffix.result}"
    }
  )
}


