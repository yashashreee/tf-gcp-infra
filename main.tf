resource "google_compute_network" "webapp-vpc" {
  name                            = var.network_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  name          = "webapp"
  ip_cidr_range = var.webapp_address
  network       = google_compute_network.webapp-vpc.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db" {
  name          = "db"
  ip_cidr_range = var.db_address
  network       = google_compute_network.webapp-vpc.self_link
}

resource "google_compute_route" "default" {
  name             = var.route_name
  network          = google_compute_network.webapp-vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

resource "google_compute_global_address" "default" {
  provider = google-beta
  name         = var.global_address_name
  address_type = var.global_address_type
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = google_compute_network.webapp-vpc.self_link
  address      = "10.3.0.5"
}

resource "google_compute_global_forwarding_rule" "private-service-access" {
   provider = google-beta
  name                  = var.global_forwarding_rule_name
  target                = "all-apis"
  network               = google_compute_network.webapp-vpc.self_link
  ip_address            = google_compute_global_address.default.self_link
  load_balancing_scheme = ""
}

resource "google_service_networking_connection" "webapp-vpc-private-connection" {
  provider                = google-beta
  network                 = google_compute_network.webapp-vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private-service-access.self_link]
}

resource "google_sql_database_instance" "default" {
  name             = var.sql_instance_name
  database_version = var.db_version
  region           = var.region

  settings {
    tier = "db-custom-1-3840"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.webapp-vpc.self_link
      require_ssl     = true

      authorized_networks {
        value           = var.db_address
      }

    }
    disk_type = "PD_SSD"
    disk_size = 100
    disk_autoresize = true
    availability_type = "REGIONAL"
    deletion_protection_enabled = false

    backup_configuration {
      enabled = true
    }  
  }
}

resource "google_sql_database" "webapp-db" {
  name     = var.sql_database_instance_name
  instance = google_sql_database_instance.default.self_link
}

resource "google_sql_user" "webapp-db-user" {
  name     = var.sql_instance_user_name
  instance = google_sql_database_instance.default.self_link
  password = random_password.webapp-db-password.result
}

resource "random_password" "webapp-db-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_compute_instance" "default" {
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
  metadata = {
    db_user = google_sql_user.webapp-db-user.name
    db_pass = db_password
    db_host = db_instance_ip
    db_name = google_sql_database.webapp-db.name
  }

  tags = ["webapp-vpc-instance", "http-server", "https-server"]
}