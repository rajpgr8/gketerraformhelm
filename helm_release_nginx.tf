provider "helm" {
  kubernetes {
    host                   = google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

data "google_client_config" "default" {
}

resource "helm_release" "nginx" {
  namespace = "default"
  name      = "nginx-release"

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
