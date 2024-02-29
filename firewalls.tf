resource "google_compute_firewall" "allow-webapp-to-internet" {
  name    = var.allow_webapp_to_internet_name
  project = var.project_id
  network = google_compute_network.webapp-vpc.self_link

  allow {
    protocol = "tcp"
    ports    = [var.app_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp-vpc-instance", "http-server", "https-server"]
  priority      = 1001
}

resource "google_compute_firewall" "deny-ssh-to-internet" {
  name    = var.deny_ssh_to_internet_name
  project = var.project_id
  network = google_compute_network.webapp-vpc.self_link

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp-vpc-instance"]
  priority      = 1000
}

resource "google_compute_firewall" "allow-sql-to-db-subnet" {
  name    = var.allow_sql_to_db_subnet_name
  project = var.project_id
  network = google_compute_network.webapp-vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = [var.db_address]
  priority      = 1000
  direction     = "INGRESS"
}

resource "google_compute_firewall" "deny-internet-to-sql-db-instance" {
  name    = var.sql_db_instance_firwall_name
  project = var.project_id
  network = google_compute_network.webapp-vpc.self_link

  deny {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db-instance"]
}
