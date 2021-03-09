# ****************************************************************
# MySQL Master
# ****************************************************************
module "mysql_master" {
  source  = "./modules/mysql"

  identifier = "master-${random_pet.name.id}"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0.21"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_encrypted    = false
  multi_az             = true
  name                 = "" # Keep empty string to start without a database

  # Creds
  username = "admin"
  password = "YourPwdShouldBeLongAndSecure!"
  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  iam_database_authentication_enabled = false

  # Network
  port                   = "3306"
  vpc_security_group_ids = [module.rds_security_group.this_security_group_id]
  subnet_ids             = module.vpc.database_subnets[*] # DB subnet group
  publicly_accessible    = false                          # Bool to control if instance is publicly accessible

  # Backup
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  backup_retention_period   = 1                                # [0] disable backups to create DB faster | Backups are required in order to create a replica [1] days
  deletion_protection       = false                            # Database Deletion Protection
  skip_final_snapshot       = true                             # Determines whether a final DB snapshot is created before the DB instance is deleted
  final_snapshot_identifier = "${random_pet.name.id}-snapshot" # Snapshot name upon DB deletion

  # Logs
  enabled_cloudwatch_logs_exports = ["general", "slowquery"]
}

# ****************************************************************
# MySQL Replica
# ****************************************************************
module "mysql_replica" {
  source  = "./modules/mysql"

  identifier = "replica-${random_pet.name.id}"

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = module.mysql_master.this_db_instance_id

  engine         = "mysql"
  engine_version = "8.0.21"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_encrypted = false
  multi_az          = false

  # Creds
  username = "" # Username and password should not be set for replicas
  password = ""

  # Network
  port                   = "3306"
  vpc_security_group_ids = [module.rds_security_group.this_security_group_id]
  create_db_subnet_group = false # Not allowed to specify a subnet group for replicas in the same region

  # Backup
  maintenance_window      = "Tue:00:00-Tue:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0 # [0] disable backups to create DB faster

  # Logs
  enabled_cloudwatch_logs_exports = ["general", "slowquery"]
}