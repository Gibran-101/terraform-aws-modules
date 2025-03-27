output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "ssh_path" {
  value = "ssh -i 'MyAWSKey.pem' ubuntu@${aws_instance.web_server.public_ip}"
}

output "ssh_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key.filename
}

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.web_server.id
}