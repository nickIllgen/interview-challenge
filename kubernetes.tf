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
          image = "809031430406.dkr.ecr.us-west-2.amazonaws.com/ibm-rest-api"
          name  = var.application_name
          env {
            name  = "AWS_ACCESS_KEY_ID"
            value = var.AWS_ACCESS_KEY_ID
          }
          env {
            name  = "AWS_SECRET_ACCESS_KEY"
            value = var.AWS_SECRET_ACCESS_KEY
          }
          env {
            name  = "REGION_NAME"
            value = var.region
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
      port        = 8080
      target_port = 80
    }
    type = "LoadBalancer"
  }
}