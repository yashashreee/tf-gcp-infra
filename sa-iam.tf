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
