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
  default     = "us-east1"
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
  default = "n2-standard-2"
}

variable "firewall" {
  default = "webapp-firewall"
}
