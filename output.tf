output "db_password" {
  value = random_password.webapp-db-password.result
}

output "db_instance_ip" {
  value = data.google_sql_database_instance.default.ip_address
}