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

# Create Firewall Rule
resource "google_compute_firewall" "allow_ssh" {
  name    = var.firewall
  network = google_compute_network.webapp-vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.webapp_address, var.db_address]
  target_tags   = ["webapp-vpc-instance"]
}


# Create Compute Engine Instance
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/$var.project_id/global/images/custom-image"
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.webapp.self_link
  }

  tags = ["webapp-vpc-instance"]
}