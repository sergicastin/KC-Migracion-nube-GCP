terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }
}

provider "google" {
  credentials = file("cred.json")
  project = "sergicastillogcp"
  region = "europe-southwest1"
  zone = "europe-southwest1-a"
}

resource "google_compute_network" "practica_red" {
  name = "red-virtual-sergi"
}

resource "google_compute_address" "practica_ip" {
  name = "static-ip-sergi"
}

resource "google_storage_bucket" "practica_bucket" {
  name = "bucket-practica-sergi"
  location = "EU"
}

resource "google_compute_instance" "practica_instance" {
  name = "instancia-terraform-sergi"
  machine_type = "e2-micro"
  tags = ["http-server","ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.practica_red.name
    access_config {
      nat_ip = google_compute_address.practica_ip.address
    }
  }
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.practica_red.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.practica_red.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
