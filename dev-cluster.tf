variable "project_name" {
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

variable "cluster_admin_password" {
  description = "password for cluster admin. Must be 16 characters at least."
}

# Configure the Google Cloud provider
provider "google" {
  project = "${var.project_name}"
  region  = "${var.cluster_region}"
}

module "gke" {
  source              = "github.com/ostelco/ostelco-terraform-modules//terraform-google-gke-cluster"
  cluster_password    = "${var.cluster_admin_password}"
  cluster_name        = "pi-dev"
  cluster_description = "Development cluster for Ostelco Pi."
  cluster_version     = "1.9.7-gke.3"
  cluster_zone        = "${var.cluster_zone}"

  # the line below makes the cluster multizone (regional)
  #cluster_additional_zones = ["europe-west1-b"]
}

module "np" {
  source         = "github.com/ostelco/ostelco-terraform-modules//terraform-google-gke-node-pool"
  cluster_name   = "${module.gke.cluster_name}"
  node_pool_zone = "${module.gke.cluster_zone}"

  node_pool_name         = "small-nodes-pool"
  initial_node_pool_size = "2"
  pool_min_node_count    = "1"
  pool_max_node_count    = "4"
  node_tags              = ["dev"]

  node_labels = {
    "env"         = "dev"
    "machineType" = "n1-standard-1"
  }
}

output "dev_cluster_endpoint" {
  value = "${module.gke.cluster_endpoint}"
}

output "dev_cluster_client_certificate" {
  value = "${module.gke.cluster_client_certificate}"
}

output "dev_cluster_client_key" {
  value = "${module.gke.cluster_client_key}"
}

output "dev_cluster_ca_certificate" {
  value = "${module.gke.cluster_ca_certificate}"
}

# the backend config for storing terraform state in GCS 
# requires setting GOOGLE_CREDNETIALS to contain the path to your Google Cloud service account json key.
terraform {
  backend "gcs" {
    bucket = "pi-ostelco-dev-terraform-state"
    prefix = "clusters/dev/state"
  }
}
