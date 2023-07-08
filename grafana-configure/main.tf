terraform {
  backend "kubernetes" {
    secret_suffix = "grafana"
    config_path   = "~/.kube/config"
  }
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "2.0.0"
    }
  }
}

data "vault_generic_secret" "graf" {
  path = "kv/grafana"
}

data "vault_generic_secret" "kolve" {
  path = "kv/kolve/develop"
}

locals {
  grafana = data.vault_generic_secret.graf.data
}

provider "grafana" {
  url  = "https://${local.grafana["domain"]}"
  auth = "${local.grafana["username"]}:${local.grafana["password"]}"
}

provider "vault" {
  address = "http://10.0.0.45:8200"
}
