terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # provider source
      version = "~> 5.85.0"  
    }
  }
}

provider "aws" {
  region     = var.aws_region  # Région AWS
  access_key = var.access_key  # Clé d'accès AWS
  secret_key = var.secret_key  # Clé secrète AWS
}

resource "aws_instance" "web" {
  ami           = var.ami_code  # ID de l'AMI (Amazon Machine Image)
  instance_type = "t2.micro"  # Type d'instance EC2 => t2.micro free tier
  key_name      = var.key_name  # clef ssh 

 # Script de configuration => JDK + tomcat10 
  user_data = <<-EOF 
              #!/bin/bash
              sudo apt update  
              sudo apt install default-jdk  
              sudo apt install tomcat10 
              sudo systemctl start tomcat10  
              sudo systemctl enable tomcat10
              EOF

  tags = {
    Name = "ECF-Server"  # Nom instance EC2
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "ecf-bucket-${random_id.suffix.hex}"  # Nom du bucket S3 + suffixe aléatoire pour garantir l'unicité
}

# Generation de suffixe
resource "random_id" "suffix" {
  byte_length = 4  # longueur suffixe
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id  # ID du bucket S3
  rule {
    object_ownership = "BucketOwnerPreferred"  
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket      = aws_s3_bucket.bucket.id  # ID du bucket S3
  acl         = "private"  # Définit la liste de contrôle d'accès (ACL) du bucket comme privée
  depends_on  = [aws_s3_bucket_ownership_controls.bucket_ownership]  # Dépendance pour s'assurer que les contrôles de propriété sont appliqués avant de définir l'ACL
}
