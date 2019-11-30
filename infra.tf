data "google_client_config" "default" {}

data "google_container_cluster" "cluster_01" {
  name = "cluster-01"
  location = "us-central1"
}

provider "google" {
  credentials = file("gcp.key.json")
  project     = "untitled-angular-spring"
  region      = "us-central1"
  zone        = "us-central1-c"
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.cluster_01.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster_01.master_auth[0].cluster_ca_certificate,
  )
}

resource "google_container_cluster" "primary" {
  name     = "cluster-01"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool-01"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "kubernetes_secret" "github_package_cred" {
  metadata {
    name = "github-package-cred"
  }

  data = {
    ".dockerconfigjson" = file("docker.config.json")
  }

  type = "kubernetes.io/dockerconfigjson"
}
