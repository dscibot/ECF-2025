resource "aws_db_instance" "mysql" {
  identifier           = var.db_identifier 
  engine               = "mysql"
  engine_version       = "8.0.40" 
  instance_class       = "db.t3.micro" 
  allocated_storage    = 20
  username             = var.db_username
  password             = var.db_password 
  publicly_accessible  = true             
  skip_final_snapshot  = true             
}