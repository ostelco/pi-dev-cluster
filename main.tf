variable "credentials_path" {
  default = "/Users/mac/pantel-tests-57d874ebc8db.json"
  description = "the path to your Google Cloud json credentials file."
}

variable "project_name" {
  default     = "pantel-tests"
  description = "Google Cloud project name."
}

variable "cluster_region" {
  default     = "europe-west1"
  description = "The region where the cluster will be created."
}


provider "google" {
  credentials = "${file(var.credentials_path)}"
  project     = "${var.project_name}"
  region      = "${var.cluster_region}"
}

module "cluster" {
  source = "github.com/ostelco/ostelco-infra//terraform-google-gke"
  project_name = "${var.project_name}"
  cluster_name = "a1234"
  cluster_region = "${var.cluster_region}"
  cluster_zone = "europe-west1-b"
  cluster_description = "a123"
  master_password = "super-secret-long-password"
}

module "np1" {
 source = "github.com/ostelco/ostelco-infra//terraform-google-nodepools"
 node_config_labels = {}
 node_config_tags = []
 node_pool_name = "a12345"
 node_pool_count = 3
 cluster_name = "a1234"
 cluster_zone = "europe-west1-b"
}
