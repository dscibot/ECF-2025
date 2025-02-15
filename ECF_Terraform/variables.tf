#Fichier de définition des variables pour le fichier main
variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3"
}
variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true 
}
variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true 
}
variable "ami_code" {
  description = "AWS AMI Key"
  type        = string
}
variable "key_name" {
  description = "AWS Key Name"
  type        = string
}

#DB Mysql
variable "db_identifier" {
  description = "Nom unique de l'instance RDS"
  type        = string
}
variable "db_username" {
  description = "Nom d'utilisateur administrateur"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Mot de passe administrateur"
  type        = string
  sensitive   = true
}
