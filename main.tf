provider "google" {
  credentials = file("../credentials/secrets.json")
  project     = var.project_id
  region      = var.region
}

data "google_client_config" "default" {
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

resource "helm_release" "nginx" {
  namespace = "default"
  name  = "nginx-release"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "9.3.6"
  
  set {
    name  = "autoscaling.enabled"
    value = "true"
  }
  set {
    name  = "autoscaling.minReplicas"
    value = 2
  }
  set {
    name  = "autoscaling.maxReplicas"
    value = 6
  }
  set {
    name  = "autoscaling.targetCPU"
    value = 50
  }
}

resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = var.k8s_version
  
  resource_labels          = {
    environment            = "development"
    created-by             = "terraform"
    owner                  = "my-gke"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name               = var.cluster_name
  location           = var.region
  cluster            = google_container_cluster.primary.name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}

resource "google_storage_bucket" "state" {
  name          = var.state_bucket
  # location      = var.region
  project       = var.project_id
  storage_class = "NEARLINE"
  labels        = {
    environment = "dev"
    created-by  = "terraform"
    owner       = "my-gke-state"
  }
}
