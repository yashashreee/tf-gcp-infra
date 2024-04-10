variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "The Google Cloud region."
  type        = string
}

variable "routing_mode" {
  description = "VPC routing mode."
  type        = string
}

variable "zone" {
  description = "The Google Cloud zone."
  type        = string
}

variable "app_port" {
  description = "Webapp PORT"
  type        = string
}

variable "tf_service_account" {
  description = "The service account to be used for Terraform."
  type        = string
}

variable "gcp_key_path" {
  description = "Path to GCP key."
  type        = string
}

variable "network_name" {
  description = "VPC network name for respective environment."
  type        = string
}

variable "webapp_address" {
  description = "Routing address for webapp subnet."
  type        = string
}

variable "db_address" {
  description = "Routing address for db subnet."
  type        = string
}

variable "route_name" {
  description = "Name of the routing table."
  type        = string
}

variable "vm_instance_template_name" {
  description = "Name of the virtual machine instance."
  type        = string
}

variable "machine_type" {
  description = "Machine type for the virtual machine."
  type        = string
}

variable "allow_webapp_to_internet_name" {
  description = "Name of the firewall rule allowing webapp to the internet."
  type        = string
}

variable "deny_ssh_to_internet_name" {
  description = "Name of the firewall rule denying SSH to the internet."
  type        = string
}

variable "allow_sql_to_db_subnet_name" {
  description = "Name of the firewall rule allowing SQL to the DB subnet."
  type        = string
}

variable "custom_image" {
  description = "Name of the custom image."
  type        = string
}

variable "global_address_name_private_access" {
  description = "Name of the global IP address for webapp private access"
  type        = string
}

variable "global_address_type" {
  description = "Type of the global IP address (INTERNAL or EXTERNAL)."
  type        = string
}

variable "global_address_ip" {
  description = "Global IP address"
  type        = string
}

variable "global_forwarding_rule_name" {
  description = "Name of the global forwarding rule for webapp."
  type        = string
}

variable "sql_instance_name" {
  description = "Name of the Cloud SQL instance for the webapp database."
  type        = string
}

variable "db_version" {
  description = "Version of the database (e.g., MYSQL_8_0)."
  type        = string
}

variable "sql_database_name" {
  description = "Name of the database instance in Cloud SQL."
  type        = string
}

variable "sql_instance_user_name" {
  description = "Name of the user for the Cloud SQL instance."
  type        = string
}

variable "sql_db_instance_firwall_name" {
  description = "Name of the firewall rule denying internet access to the SQL DB instance."
  type        = string
}

variable "fully_qualified_domain_name" {
  description = "Fully qualified domain name"
  type        = string
}

variable "dns_zone_name" {
  description = "DNS public zone name."
  type        = string
}

variable "vm_service_account_id" {
  description = "VM service account ID."
  type        = string
}

variable "vm_service_account_name" {
  description = "VM service account name."
  type        = string
}

variable "pubsub_topic_name" {
  description = "Pub/Sub topic name."
  type        = string
}

variable "pubsub_subscription_name" {
  description = "Pub/Sub topic subscription name."
  type        = string
}

variable "cloudfunctions_function_name" {
  description = "Cloud funtions instance name"
  type        = string
}

variable "source_archive_bucket_name" {
  description = "Source archive bucket name"
  type        = string
}

variable "source_archive_object_path" {
  description = "Source archive object path"
  type        = string
}

variable "mailgun_api_key" {
  description = "Mailgun API key"
  type        = string
}

variable "domain_name" {
  description = "Your domain name"
  type        = string
}

variable "vpc_access_connector_name" {
  description = "VPC access connector."
  type        = string
}

variable "vpc_access_connector_name_cidr" {
  description = "CIDR range for access connector."
  type        = string
}

variable "cloud_function_sa_email" {
  description = "Email for cloud function SA"
  type        = string
}

variable "health_check_name" {
  description = "Name of the webapp health check on /healthz"
  type        = string
}

variable "autoscaler_name" {
  description = "Name of the auto scaler"
  type        = string
}

variable "group_manager_name" {
  description = "Name of the instances group manager"
  type        = string
}

variable "ssl_certi_name" {
  description = "Name of SSL certificate"
  type        = string
}

variable "backend_service_name" {
  description = "Name of backend service"
  type        = string
}

variable "url_map_name" { type = string }
variable "target_https_proxy_name" { type = string }

variable "global_address_name_load_balancer" {
  description = "Global address name for webapp load balancer."
  type        = string
}

variable "key_ring_name" {
  description = "Key ring name in your region."
  type        = string
}

variable "vm_key_name" {
  description = "CMEK for Virtual Machine"
  type        = string
}

variable "sql_key_name" {
  description = "CMEK for Cloud SQL"
  type        = string
}

variable "bucket_key_name" {
  description = "CMEK for Cloud Storage"
  type        = string
}
