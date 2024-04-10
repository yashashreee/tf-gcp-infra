provider "google" {
  credentials                 = file(var.gcp_key_path)
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = var.tf_service_account
}

provider "google-beta" {
  credentials                 = file(var.gcp_key_path)
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = var.tf_service_account
}
