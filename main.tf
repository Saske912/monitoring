terraform {
  backend "kubernetes" {
    secret_suffix = "monitoring"
    config_path   = "~/.kube/config"
  }
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "2.0.0"
    }
    vault = {
      source = "hashicorp/vault"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.21.1-beta.1"
    }
  }
}
