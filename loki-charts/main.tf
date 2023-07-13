terraform {
  backend "kubernetes" {
    secret_suffix = "loki"
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


data "vault_generic_secret" "cluster" {
  path = "kv/cluster"
}

data "vault_generic_secret" "minio" {
  path = "kv/minio"
}

resource "helm_release" "loki" {
  chart            = "loki"
  name             = "loki"
  namespace        = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  create_namespace = true
  version          = "5.8.9"
  # set {
  #   name  = "loki.storage.s3.endpoint"
  #   value = data.vault_generic_secret.minio.data["host"]
  # }
  # set {
  #   name  = "loki.storage.s3.region"
  #   value = data.vault_generic_secret.minio.data["region"]
  # }
  # set {
  #   name  = "loki.storage.s3.secretAccessKey"
  #   value = data.vault_generic_secret.minio.data["secret_key"]
  # }
  # set {
  #   name  = "loki.storage.s3.accessKeyId"
  #   value = data.vault_generic_secret.minio.data["key"]
  # }
  # set {
  #   name  = "loki.storage.s3.insecure"
  #   value = true
  # }
  set {
    name  = "minio.enabled"
    value = true
  }
  set {
    name  = "global.clusterDomain"
    value = data.vault_generic_secret.cluster.data["domain"]
  }
  set {
    name  = "write.replicas"
    value = 1
  }
  set {
    name  = "read.replicas"
    value = 1
  }
  set {
    name  = "backend.replicas"
    value = 1
  }
  set {
    name  = "loki.auth_enabled"
    value = false
  }
  set {
    name  = "monitoring.selfMonitoring.grafanaAgent.installOperator"
    value = false
  }
  set {
    name  = "monitoring.lokiCanary.enabled"
    value = false
  }
  set {
    name  = "test.enabled"
    value = false
  }
  set {
    name  = "loki.commonConfig.replication_factor"
    value = 1
  }
  set {
    name  = "monitoring.rules.enabled"
    value = false
  }
  set {
    name  = "monitoring.rules.alerting"
    value = false
  }
  set {
    name  = "monitoring.serviceMonitor.enabled"
    value = false
  }
  set {
    name  = "monitoring.selfMonitoring.enabled"
    value = false
  }
}

resource "helm_release" "promtail" {
  repository = "https://grafana.github.io/helm-charts"
  name       = "promtail"
  chart      = "promtail"
  namespace  = "loki"
}
