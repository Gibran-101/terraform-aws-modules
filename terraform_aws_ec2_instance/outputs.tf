output "public_ssh_key" {
  description = "Public part of the generated SSH key"
  value       = tls_private_key.ssh_key.public_key_openssh
}
