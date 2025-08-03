terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

module "instances" {
  source = "./modules/instances"
}

module "storage" {
  source = "./modules/storage"
}

terraform {
  backend "gcs" {
    bucket = "tf-bucket-405947"
    prefix = "terraform/state"
  }
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "10.0.0"
  network_name = "tf-vpc-134606"
  routing_mode = "GLOBAL"
  project_id = var.project_id

  subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = var.region
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = var.region
        },
    ]
}

resource "google_compute_firewall" "tf-firewall" {
  name = "tf-firewall"

  network = module.network.network_name
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
