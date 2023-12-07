resource "grafana_data_source" "redis" {
  type                = "redis-datasource"
  name                = "Redis"
  url                 = "${local.redis["host"]}:6379"
  database_name       = "0"
  basic_auth_username = "default"
  secure_json_data_encoded = jsonencode({
    password = local.redis["password"]
  })
}

resource "grafana_data_source" "postgresql" {
  type                = "postgres"
  name                = "PostgreSQL"
  url                 = local.postgres["IMPLICIT_HOST"]
  username            = postgresql_role.grafana.name
  basic_auth_enabled  = false
  basic_auth_username = postgresql_role.grafana.name
  access_mode         = "proxy"
  secure_json_data_encoded = jsonencode({
    password = postgresql_role.grafana.password
  })
  json_data_encoded = jsonencode({
    database        = var.postgresql_database_metrics_target
    sslmode         = "disable"
    postgresVersion = 1510
    tlsAuth         = false
  })
}

data "vault_generic_secret" "grafana" {
  path = var.grafana_data_vault_path
}

data "vault_generic_secret" "redis" {
  path = var.redis_data_vault_path
}

data "vault_generic_secret" "postgresql" {
  path = var.postgresql_data_vault_path
}

locals {
  grafana  = data.vault_generic_secret.grafana.data
  postgres =data.vault_generic_secret.postgresql.data
  redis    = data.vault_generic_secret.redis.data
}