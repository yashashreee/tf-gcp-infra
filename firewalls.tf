resource "google_compute_firewall" "allow-webapp-to-lb" {
  name          = "allow-webapp-to-lb"
  direction     = "INGRESS"
  network       = google_compute_network.webapp-vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", google_compute_global_address.webapp-load-balancer.address]

  allow {
    protocol = "tcp"
    ports = ["443", "3306", "3000"]
  }

  target_tags = ["allow-health-check"]
}

resource "google_compute_firewall" "deny-ssh-to-internet" {
  name    = var.deny_ssh_to_internet_name
  network = google_compute_network.webapp-vpc.self_link

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp-vm-template"]
  priority      = 1000
}

resource "google_compute_firewall" "allow-sql-to-db-subnet" {
  name    = var.allow_sql_to_db_subnet_name
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
  network = google_compute_network.webapp-vpc.self_link

  deny {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["db-instance"]
}
