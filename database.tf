resource "google_sql_database_instance" "webapp-cloudsql-instance" {
  name                = var.sql_instance_name
  database_version    = var.db_version
  region              = var.region
  deletion_protection = false
  depends_on          = [google_service_networking_connection.webapp-vpc-private-connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.webapp-vpc.self_link
      enable_private_path_for_google_cloud_services = true
    }
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true
    availability_type = "REGIONAL"

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
  }
}

resource "google_sql_database" "webapp-db" {
  name            = var.sql_database_name
  instance        = google_sql_database_instance.webapp-cloudsql-instance.name
  deletion_policy = "ABANDON"
}

resource "google_sql_user" "webapp-db-user" {
  name     = var.sql_instance_user_name
  instance = google_sql_database_instance.webapp-cloudsql-instance.name
  password = random_password.webapp-db-password.result
}

resource "random_password" "webapp-db-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
