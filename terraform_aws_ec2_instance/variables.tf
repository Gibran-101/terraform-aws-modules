variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}
