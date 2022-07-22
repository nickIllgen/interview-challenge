provider "aws" {
  region = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "nickillgen"
    workspaces = {
      name = "ibm-rest-api-nick-illgen"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "ibm-rest-api" {
  metadata {
    name = "ibm-rest-api"
  }
}

resource "kubernetes_deployment" "ibm-rest-api" {
  metadata {
    name      = var.application_name
    namespace = kubernetes_namespace.ibm-rest-api.id
    labels = {
      app = var.application_name
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = var.application_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.application_name
        }
      }
      spec {
        container {
          image = "809031430406.dkr.ecr.us-west-2.amazonaws.com/ibm-rest-api:latest"
          name  = var.application_name
          env {
            name  = "REGION_NAME"
            value = var.region
          }
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ibm-rest-api" {
  metadata {
    name      = var.application_name
    namespace = kubernetes_namespace.ibm-rest-api.id
  }
  spec {
    selector = {
      app = kubernetes_deployment.ibm-rest-api.metadata[0].labels.app
    }
    port {
      port        = 5000
      target_port = 5000
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
}

# Set up the persitent storage to store data: use mysql image from mysql
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim
resource "kubernetes_persistent_volume" "sql-pv-volume" {
  metadata {
    name = "sql-pv-volume"
    labels = {
      type = "local"
    }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/mnt/data"
      }
    }
    persistent_volume_reclaim_policy = "Retain"
  }
}

resource "kubernetes_persistent_volume_claim" "sql-pv-claim" {
  metadata {
    name = "sql-pv-claim"
  }
  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "mysql-server" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.ibm-rest-api.id
    labels = {
      app = "db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "db"
      }
    }
    template {
      metadata {
        labels = {
          app = "db"
        }
      }
      spec {
        container {
          image             = "809031430406.dkr.ecr.us-west-2.amazonaws.com/mysql"
          image_pull_policy = "Never"
          name              = var.application_name
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "ibm-rest-api-secrets"
                key  = "db_root_password"
              }
            }
          }
          port {
            container_port = 3306
            name           = "db-container"
          }
          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
          volume {
            name = "mysql-persistent-storage"
            persistent_volume_claim = {
              claim_name = "sql-pv-claim"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.ibm-rest-api.id
  }
  spec {
    selector = {
      app = "db"
    }
    port {
      port        = 3306
      target_port = 3306
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
}