resource "google_service_account" "vm_service_account" {
  account_id   = var.vm_service_account_id
  display_name = var.vm_service_account_name
}

resource "google_project_iam_binding" "vm_sa_logging_role" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_project_iam_binding" "vm_sa_monitoring_role" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_project_iam_binding" "sql_sa_cloud_admin_role" {
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_sql_database_instance.webapp-cloudsql-instance.service_account_email_address}",
  ]
}

resource "google_pubsub_topic_iam_binding" "publisher_access" {
  topic = google_pubsub_topic.verify_email.name
  role  = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${var.cloud_function_sa_email}",
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.send-verification-email.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "sql_crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.cloudsql-encryption-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
     "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_project_service_identity" "compute_engine_admin_key" {
  provider = google-beta
  service  = "compute.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "vm_crypto_key" {
  crypto_key_id = google_kms_crypto_key.vm-encryption-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.compute_engine_admin_key.email}",
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

data "google_storage_project_service_account" "gcp_sa_storage" {}

resource "google_kms_crypto_key_iam_binding" "gcs_crypto_key" {
  crypto_key_id = google_kms_crypto_key.gcs-encryption-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
     "serviceAccount:${google_service_account.vm_service_account.email}",
    "serviceAccount:${data.google_storage_project_service_account.gcp_sa_storage.email_address}",
    "serviceAccount:${var.cloud_function_sa_email}",
  ]
}

# resource "google_kms_crypto_key_iam_binding" "gcs_object_crypto_key" {
#   crypto_key_id = google_kms_crypto_key.gcs-encryption-key.id
#   role          = "roles/storage.objectAdmin"

#   members = [
#     "serviceAccount:${data.google_storage_project_service_account.gcp_sa_storage.email_address}",
#     "serviceAccount:${var.cloud_function_sa_email}",
#   ]
# }