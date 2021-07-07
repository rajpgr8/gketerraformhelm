variable "region" {
  type    = string
  default = "us-east1"
}

variable "project_id" {
  type    = string
}

variable "network" {
  type    = string
  default = "default"
}
variable "subnetwork" {
  type    = string
  default = "default"
}

variable "cluster_name" {
  type    = string
  default = "cluster-gke-2"
}

variable "k8s_version" {
  type = string
  default = "1.19.10-gke.1700"
  #default = "1.18.17-gke.1901"
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 2
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "state_bucket" {
  type    = string 
}
