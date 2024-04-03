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
  name          = var.global_address_name_private_access
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

resource "google_compute_region_instance_template" "webapp-vm-instance-template" {
  name_prefix  = var.vm_instance_template_name
  machine_type = var.machine_type
  tags         = ["allow-health-check", "webapp-vm-template"]

  disk {
    source_image = "projects/${var.project_id}/global/images/${var.custom_image}"
    disk_size_gb = 100
    disk_type    = "pd-balanced"
    boot         = true
    auto_delete  = true
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
    db_port      = var.app_port
    pubsub_topic = google_pubsub_topic.verify_email.name
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata_startup_script = file("./startup.sh")
}

resource "google_dns_record_set" "webapp-dns-record" {
  name         = var.fully_qualified_domain_name
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone_name
  rrdatas      = [google_compute_global_address.webapp-load-balancer.address]
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
    MAILGUN_DOMAIN                    = var.domain_name
  }

  vpc_connector         = google_vpc_access_connector.vpc-connector.name
  service_account_email = var.cloud_function_sa_email
}

# Autoscaler and Load Balancer
resource "google_compute_health_check" "webpp-health-check" {
  name                = var.health_check_name
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5

  http_health_check {
    request_path = "/healthz"
    port         = var.app_port
  }
}

resource "google_compute_region_autoscaler" "webapp-autoscaler" {
  name   = var.autoscaler_name
  target = google_compute_region_instance_group_manager.instances-group-manager.id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_region_instance_group_manager" "instances-group-manager" {
  name                      = var.group_manager_name
  region                    = var.region
  distribution_policy_zones = ["us-east1-b", "us-east1-c", "us-east1-d"]
  version {
    instance_template = google_compute_region_instance_template.webapp-vm-instance-template.self_link
    name              = "primary"
  }

  auto_healing_policies {
    health_check = google_compute_health_check.webpp-health-check.id
    initial_delay_sec = 300
  }

  named_port {
    name = "webapp-http"
    port = var.app_port
  }

  base_instance_name = "webapp-vm"
  target_size        = 3
}

resource "google_compute_managed_ssl_certificate" "webapp-ssl-cert" {
  name = var.ssl_certi_name
  managed {
    domains = [var.fully_qualified_domain_name]
  }
}

resource "google_compute_backend_service" "webapp-backend-service" {
  name                  = var.backend_service_name
  port_name             = "webapp-http"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = true
  health_checks         = [google_compute_health_check.webpp-health-check.id]

  backend {
    group           = google_compute_region_instance_group_manager.instances-group-manager.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "webapp-url-map" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.webapp-backend-service.id
}

resource "google_compute_target_https_proxy" "webapp-proxy" {
  name             = var.target_https_proxy_name
  url_map          = google_compute_url_map.webapp-url-map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.webapp-ssl-cert.id]
}

resource "google_compute_global_address" "webapp-load-balancer" {
  name = var.global_address_name_load_balancer
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = 443
  target                = google_compute_target_https_proxy.webapp-proxy.id
  ip_address            = google_compute_global_address.webapp-load-balancer.address
}
