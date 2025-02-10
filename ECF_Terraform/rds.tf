resource "aws_db_instance" "ecf_rds" {
  identifier             = var.db_identifier 
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"  # Compatible Free Tier
  allocated_storage      = 20  # Free Tier max : 20 Go
  storage_type           = "gp2"
  db_name                = "ecf2025_db"
  username               = var.db_username
  password               = var.db_password  # ⚠️ À sécuriser avec AWS Secrets Manager en prod
  skip_final_snapshot    = true  # Pour éviter les frais de snapshot
  publicly_accessible    = true  # Permet de tester facilement en dev
}
