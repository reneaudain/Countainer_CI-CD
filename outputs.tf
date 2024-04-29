
output "instance_id" {
  value = module.ec2_instance.id
}
output "ssh_address" {
  value = "ssh -i ${aws_key_pair.generated_key.key_name} ubuntu@${module.ec2_instance.public_dns}"
}
output "ssh_permissions" {
  description = "permisions command for key pair"
  value = "chmod 400 ${aws_key_pair.generated_key.key_name}"
}
output "user_key" {
  value = aws_iam_access_key.git_key
  sensitive = true
}
