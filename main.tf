resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "webapp" {
  name          = "webapp"
  ip_cidr_range = var.webapp_address
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "db" {
  name          = "db"
  ip_cidr_range = var.db_address
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_route" "default" {
  name              = "default-route"
  network           = google_compute_network.vpc.name
  dest_range        = "0.0.0.0/0"
  next_hop_gateway  = "default-internet-gateway"
  priority          = 100
  tags              = ["webapp"]
}
