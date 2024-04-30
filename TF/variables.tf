variable "region" {
  description = "AWS region"
  type        = string
  default     = "foo"
}
variable "key_name" {
  description = "Controller instance key pair name"
  type = string
  default = "foo"
}
variable "instance_type" {
  description = "The KubeController instance type"
  type = string
  default = "t2.micro"
}
variable "cluster_security_group_id" {
  description = "security group id for the eks"
  type = string
  default = "value"
}
variable "owner_arn" {
  type = string
  sensitive = true 
  description = "Owners ARN"
  default = "foo"
}
variable "allow_all" {
  description = "all traffic cidr"
  default = "0.0.0.0/0"
}
variable "Access_key" {
  default = "foo"
  sensitive = true
  description = "Access_key for ecr user"
}
variable "Secret_key" {
  default = "foo"
  sensitive = true
  description = "secret_key for ecr user"
}
variable "account_id" {
  description = "replace with your account id here"
  sensitive = true
  default = "foo"
  
}
