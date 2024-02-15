variable "project_id" {
  description = "The Google Cloud project ID."
}

variable "region" {
  description = "The Google Cloud region."
}

variable "zone" {
  description = "The Google Cloud zone."
}

variable "tf_service_account" {
  description = "The service account to be used for Terraform."
}

variable "gcp_key_path" {
  description = "Path to GCP key."
}

variable "network_name" {
  description = "VPC network name for respective environment."
}

variable "webapp_address" {
  description = "Routing address for webapp subnet."
}

variable "db_address" {
  description = "Routing address for db subnet."
}
