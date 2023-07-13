terraform {
  backend "kubernetes" {
    secret_suffix = "monitoring"
    config_path   = "~/.kube/config"
  }
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    vault = {
      source = "hashicorp/vault"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    minio = {
      source  = "Ferlab-Ste-Justine/minio"
      version = "0.2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "vault" {
  address = "http://10.0.0.45:8200"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "prometheus" {
  chart            = "prometheus"
  name             = "prometheus"
  namespace        = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  create_namespace = true
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "prometheus-pushgateway.enabled"
    value = false
  }
  set {
    name  = "server.persistentVolume.size"
    value = "40Gi"
  }
  set {
    name  = "alertmanager.enabled"
    value = false
  }
  set {
    name  = "server.retention"
    value = "10d"
  }
}

data "vault_generic_secret" "graf" {
  path = "kv/grafana"
}

data "vault_generic_secret" "kolve" {
  path = "kv/kolve/develop"
}

data "vault_generic_secret" "mail" {
  path = "kv/mail"
}

data "vault_generic_secret" "influx" {
  path = "kv/influxdb"
}

locals {
  grafana = data.vault_generic_secret.graf.data
  mail    = jsondecode(data.vault_generic_secret.graf.data["mail"])
}

resource "kubernetes_namespace_v1" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "kubernetes_secret_v1" "smtp" {
  metadata {
    name      = "smtp"
    namespace = kubernetes_namespace_v1.grafana.metadata[0].name
  }
  data = {
    "user"     = "${local.mail.user}@${local.mail.domain}"
    "password" = local.grafana["password"]
  }
}

resource "helm_release" "grafana" {
  chart      = "grafana"
  name       = "grafana"
  namespace  = kubernetes_namespace_v1.grafana.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.57.4"
  set {
    name  = "persistence.enabled"
    value = true
  }
  set {
    name  = "deploymentStrategy.type"
    value = "Recreate"
  }
  set {
    name  = "adminUser"
    value = data.vault_generic_secret.graf.data["username"]
  }
  set {
    name  = "adminPassword"
    value = data.vault_generic_secret.graf.data["password"]
  }
  set {
    name  = "smtp.existingSecret"
    value = kubernetes_secret_v1.smtp.metadata[0].name
  }
  set_list {
    name  = "plugins"
    value = ["redis-datasource"]
  }
  values = [templatefile("grafanaValues.yml", { domain = local.grafana["domain"],
    mail         = data.vault_generic_secret.mail.data, grafana = local.grafana,
    grafana-mail = local.mail, influx = data.vault_generic_secret.influx.data
  })]
}
