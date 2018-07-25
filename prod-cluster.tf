#variable "credentials_path" {
#  type        = "string"
#  description = "the path to your Google Cloud json credentials file."
#}

variable "project_name" {
  type        = "string"
  description = "Google Cloud project ID."
  default     = "pi-ostelco-dev"
}

variable "cluster_region" {
  default     = "europe-west1"
  description = "The region where the cluster will be created."
}

variable "cluster_zone" {
  default     = "europe-west1-c"
  description = "The zone where the cluster will be created."
}

# Configure the Google Cloud provider
provider "google" {
  #  credentials = "${file(var.credentials_path)}"
  project = "${var.project_name}"
  region  = "${var.cluster_region}"
}

module "gke" {
  source              = "terraform-google-gke-cluster"
  cluster_password    = "tkj45fyu984ghgw2gfn0786"
  cluster_name        = "test-cluster"
  cluster_description = "module example."
  cluster_version     = "1.9.7-gke.3"
  cluster_zone        = "${var.cluster_zone}"

  # the line below makes the cluster multizone (regional)
  #cluster_additional_zones = ["europe-west1-b"]
}

module "np" {
  source         = "terraform-google-gke-node-pool"
  cluster_name   = "${module.gke.cluster_name}"
  node_pool_zone = "${module.gke.cluster_zone}"

  #cluster_region = "${module.gke.cluster_region}"
  node_pool_name  = "pool1"
  node_pool_count = "1"
  node_tags       = ["tag1", "tag2"]

  node_labels = {
    "key1" = "value1"
    "key2" = "value2"
  }
}

output "cluster_endpoint" {
  value = "${module.gke.cluster_endpoint}"
}

output "cluster_client_certificate" {
  value = "${module.gke.cluster_client_certificate}"
}

output "cluster_client_key" {
  value = "${module.gke.cluster_client_key}"
}

output "cluster_ca_certificate" {
  value = "${module.gke.cluster_ca_certificate}"
}

# the backend config for storing terraform state in GCS 
# requires setting GOOGLE_CREDNETIALS to contain the path to your Google Cloud service account json key.
terraform {
  backend "gcs" {
    bucket = "pi-development-terraform-state"
    prefix = "clusters/dev/state"
  }
}
