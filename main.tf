terraform {
  backend "gcs" {
    bucket = "tf-bucket-634907"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.55.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  zone = var.zone
}

module "instances" {

  source = "./modules/instances"
  zone   = var.zone
}
module "storage" {
  source = "./modules/storage"
}
module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "3.4.0"
  project_id   = var.project_id
  network_name = var.vpc_name
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet has a description"
    }
  ]
}
resource "google_compute_firewall" "tf-firewall" {
  name    = "tf-firewall"
  network = "projects/${var.project_id}/global/networks/tf-vpc-707736"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
