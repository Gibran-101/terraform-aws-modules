variable "region" {
  description = "AWS geographical region where resources will be deployed. This determines the physical location of your infrastructure and impacts latency, compliance, and service availability. Default is 'us-east-1' (N. Virginia), which is typically used for testing and has wide service support."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Specific Availability Zone within the chosen region. Availability Zones are isolated locations within a region that provide additional fault tolerance. 'us-east-1a' is the first AZ in the N. Virginia region. Choose based on your high availability and disaster recovery requirements."
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "AWS EC2 instance type that defines the hardware of the host computer used for your instance. 't2.micro' is part of the AWS Free Tier, suitable for low-traffic applications, development, and testing. It provides 1 vCPU and 1 GiB of memory. Consider larger types for production workloads with higher compute or memory needs."
  type        = string
  default     = "t2.micro"
}
