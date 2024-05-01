
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
output "user_id" {
  value = aws_iam_access_key.git_key.id
  description = "Access Id"
  sensitive = true
}
output "user_secret" {
  description = "Secret key"
  sensitive = true
  value = aws_iam_access_key.git_key.secret
}
output "key_name" {
  value = aws_key_pair.generated_key.key_name
  sensitive = true
  description = "Instance Key Pair name"
}
output "EC2_PEM_KEY" {
  description = "Key Pair Value"
  sensitive = true
  value = aws_key_pair.generated_key.public_key
}
