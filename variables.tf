variable "project_id" {
  description = "The Google Cloud project ID."
}

variable "region" {
  description = "The Google Cloud region."
  default     = "us-east1"
}

variable "routing_mode" {
  description = "VPC routing mode."
  default     = "REGIONAL"
}

variable "zone" {
  description = "The Google Cloud zone."
  default     = "us-east1-b"
}

variable "tf_service_account" {
  description = "The service account to be used for Terraform."
}

variable "gcp_key_path" {
  description = "Path to GCP key."
}

variable "network_name" {
  description = "VPC network name for respective environment."
  default     = "dev-netowrk"
}

variable "webapp_address" {
  description = "Routing address for webapp subnet."
  default     = "10.0.1.0/24"
}

variable "db_address" {
  description = "Routing address for db subnet."
  default     = "10.0.2.0/24"
}

variable "route_name" {
  default = "webapp-route"
}

variable "instance_name" {
  default = "webapp-vpc-instance"
}

variable "machine_type" {
  default = "e2-standard-2"
}

variable "allow_webapp_to_internet_name" {
  default = "allow-webapp-to-internet"
}

variable "deny_ssh_to_internet_name" {
  default = "deny-ssh-to-internet"
}

variable "allow_sql_to_db_subnet_name" {
  default = "allow-sql-to-db-subnet"
}

variable "custom_image" {
  default = "csye6225-custom-image"
}

variable "app_port" {
  description = "Webapp PORT"
}

variable "global_address_name" {
  default = "webapp-global-connect-ip"
}

variable "global_address_type" {
  default = "INTERNAL"
}

variable "global_forwarding_rule_name" {
  default = "webapp-globalrule"
}

variable "sql_instance_name" {
  default = "webapp-cloudsql-instance"
}

variable "db_version" {
  default = "MYSQL_8_0"
}

variable "sql_database_instance_name" {
  default = "webapp-db"
}

variable "sql_instance_user_name" {
  default = "webapp-db-user"
}

variable "sql_db_instance_firwall_name" {
  default = "deny-internet-to-sql-db-instance"
}