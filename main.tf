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
    # grafana = {
    #   source  = "grafana/grafana"
    #   version = "2.0.0"
    # }
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
  #   set {
  #     name  = "server.baseURL"
  #     value = "prom.kolve.ru"
  #   }
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
  values = [templatefile("grafanaValues.yml", { domain = local.grafana["domain"],
    mail         = data.vault_generic_secret.mail.data, grafana = local.grafana,
    grafana-mail = local.mail
  })]
}



# data "vault_generic_secret" "minio" {
#   path = "kv/minio"
# }

# data "vault_generic_secret" "cluster" {
#   path = "kv/cluster"
# }

# resource "helm_release" "loki" {
#   chart            = "loki"
#   name             = "loki"
#   namespace        = "loki"
#   repository       = "https://grafana.github.io/helm-charts"
#   create_namespace = true
#   version          = "5.8.9"
#   set {
#     name  = "loki.storage.s3.endpoint"
#     value = data.vault_generic_secret.minio.data["host"]
#   }
#   set {
#     name  = "loki.storage.s3.region"
#     value = data.vault_generic_secret.minio.data["region"]
#   }
#   set {
#     name  = "loki.storage.s3.secretAccessKey"
#     value = data.vault_generic_secret.minio.data["secret_key"]
#   }
#   set {
#     name  = "loki.storage.s3.accessKeyId"
#     value = data.vault_generic_secret.minio.data["key"]
#   }
#   set {
#     name  = "test.prometheusAddress"
#     value = "http://prometheus-server.prometheus"
#   }
#   set {
#     name  = "global.clusterDomain"
#     value = data.vault_generic_secret.cluster.data["domain"]
#   }
#   set {
#     name  = "write.replicas"
#     value = 1
#   }
#   set {
#     name  = "write.autoscaling.enabled"
#     value = true
#   }
#   set {
#     name  = "read.replicas"
#     value = 1
#   }
#   set {
#     name  = "read.autoscaling.enabled"
#     value = true
#   }
#   set {
#     name  = "backend.replicas"
#     value = 1
#   }
#   set {
#     name  = "backend.autoscaling.enabled"
#     value = true
#   }
# }
