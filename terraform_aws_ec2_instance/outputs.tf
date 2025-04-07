output "instance_public_ip" {
 description = "Public IP address of the EC2 instance. This is the externally accessible IP that can be used to connect to the instance from the internet. Note: Public IP can change if the instance is stopped and started."
 value       = aws_instance.web_server.public_ip
}

output "ssh_connect_command" {
 description = "Complete SSH command to connect to the EC2 instance. Includes the private key path and default Ubuntu user. Use this command in your terminal to establish a secure shell connection to the server."
  value       = "ssh -i ${abspath(local_file.private_key.filename)} ubuntu@${aws_instance.web_server.public_ip}"
}

output "ssh_key_path" {
 description = "Filesystem path to the generated SSH private key file. This key is used for authenticating your connection to the EC2 instance. Keep this file secure and do not share it publicly."
 value       = local_file.private_key.filename
}

output "instance_id" {
 description = "Unique identifier for the created EC2 instance within AWS. This ID is used for managing the instance through AWS CLI, console, or Terraform, and can be referenced in other AWS resource configurations."
 value       = aws_instance.web_server.id
}

output "private_key_path" {
  description = "It prints the absolute file path to the generated .pem file"
  value = abspath(local_file.private_key.filename)
}
