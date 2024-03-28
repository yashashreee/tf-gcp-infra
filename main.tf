resource "google_compute_network" "webapp-vpc" {
  name                            = var.network_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  name                     = "webapp"
  region                   = var.region
  ip_cidr_range            = var.webapp_address
  network                  = google_compute_network.webapp-vpc.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db" {
  name          = "db"
  region        = var.region
  ip_cidr_range = var.db_address
  network       = google_compute_network.webapp-vpc.self_link
}

resource "google_vpc_access_connector" "vpc-connector" {
  name          = var.vpc_access_connector_name
  region        = var.region
  network       = google_compute_network.webapp-vpc.name
  ip_cidr_range = var.vpc_access_connector_name_cidr
}

resource "google_compute_route" "default" {
  name             = var.route_name
  network          = google_compute_network.webapp-vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

resource "google_compute_global_address" "webapp-private-ip-alloc" {
  name          = var.global_address_name
  address_type  = var.global_address_type
  purpose       = "VPC_PEERING"
  prefix_length = 24
  network       = google_compute_network.webapp-vpc.self_link
}

resource "google_service_networking_connection" "webapp-vpc-private-connection" {
  network                 = google_compute_network.webapp-vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.webapp-private-ip-alloc.name]
}

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

resource "google_compute_instance" "webapp-vpc-instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/${var.project_id}/global/images/${var.custom_image}"
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.webapp-vpc.self_link
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {}
  }

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    db_user      = google_sql_user.webapp-db-user.name
    db_pass      = google_sql_user.webapp-db-user.password
    db_host      = google_sql_database_instance.webapp-cloudsql-instance.private_ip_address
    db_name      = google_sql_database.webapp-db.name
    pubsub_topic = google_pubsub_topic.verify_email.name
  }

  metadata_startup_script = file("./startup.sh")

  tags = ["webapp-vpc-instance", "http-server", "https-server"]
}

resource "google_dns_record_set" "webapp-dns-record" {
  name         = var.domain_name
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone_name
  rrdatas      = [google_compute_instance.webapp-vpc-instance.network_interface[0].access_config[0].nat_ip]
}

# Phb/Sub
resource "google_pubsub_topic" "verify_email" {
  name                       = var.pubsub_topic_name
  message_retention_duration = "604800s"
}

resource "google_pubsub_subscription" "verify-email-subscription" {
  name  = var.pubsub_subscription_name
  topic = google_pubsub_topic.verify_email.name
}

resource "google_storage_bucket" "bucket" {
  name     = var.source_archive_bucket_name
  location = var.region
}

resource "google_storage_bucket_object" "archive" {
  name   = "functions.zip"
  bucket = google_storage_bucket.bucket.name
  source = var.source_archive_object_path
}

resource "google_cloudfunctions_function" "send-verification-email" {
  name    = var.cloudfunctions_function_name
  region  = var.region
  runtime = "nodejs20"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "sendVerificationLink"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.verify_email.name
  }

  environment_variables = {
    CLOUDSQL_INSTANCE_CONNECTION_NAME = google_sql_database_instance.webapp-cloudsql-instance.connection_name
    DB_NAME                           = google_sql_database.webapp-db.name
    DB_USER                           = google_sql_user.webapp-db-user.name
    DB_PASS                           = google_sql_user.webapp-db-user.password
    MAILGUN_API_KEY                   = var.mailgun_api_key
    MAILGUN_DOMAIN                    = var.mailgun_domain
  }

  vpc_connector         = google_vpc_access_connector.vpc-connector.name
  service_account_email = var.cloud_function_sa_email
}
