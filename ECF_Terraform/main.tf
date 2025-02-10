terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_instance" "web" {
  ami           = var.ami_code  
  instance_type = "t2.micro"
  key_name      =  var.key_name

  user_data = <<-EOF
              #!/bin/bash
			  sudo apt update
			  sudo apt install default-jdk #default-jdk => V17
			  sudo apt install tomcat10
              sudo systemctl start tomcat
              sudo systemctl enable tomcat
              EOF

  tags = {
    Name = "ECF-Server"
  }
}


resource "aws_s3_bucket" "bucket" {
  bucket = "ecf-bucket-${random_id.suffix.hex}"  
}

# Random name 
resource "random_id" "suffix" {
  byte_length = 4

}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket      = aws_s3_bucket.bucket.id
  acl         = "private"
  depends_on  = [aws_s3_bucket_ownership_controls.bucket_ownership]
}
