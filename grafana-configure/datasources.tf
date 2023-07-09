data "vault_generic_secret" "influx" {
  path = "kv/influxdb"
}
locals {
  influxdb = data.vault_generic_secret.influx.data
}

resource "grafana_data_source" "inflxudb" {
  type = "influxdb"
  name = "influxDBv2"
  url  = "http://influxdb.metrics:8086"
  json_data_encoded = jsonencode({
    version           = "Flux"
    httpMode          = "POST"
    organization      = local.influxdb["organization"]
    defaultBucket     = local.influxdb["bucket"]
    timeout           = 5
    tlsAuth           = false
    tlsAuthWithCACert = false
  })
  secure_json_data_encoded = jsonencode({
    token = local.influxdb["token"]
  })
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  url        = "http://prometheus-server.prometheus"
  is_default = true
}

data "vault_generic_secret" "redis" {
  path = "kv/redis"
}

resource "grafana_data_source" "redis" {
  type          = "redis-datasource"
  name          = "Redis"
  url           = "redis-headless.redis:6379"
  database_name = "0"
  secure_json_data_encoded = jsonencode({
    password = data.vault_generic_secret.redis.data["password"]
  })
}

resource "grafana_data_source" "postgresql" {
  type               = "postgres"
  name               = "PostgreSQL"
  url                = "${local.postgres["service"]}.${local.postgres["namespace"]}"
  username           = data.vault_generic_secret.grafana.data["username"]
  basic_auth_enabled = false
  access_mode        = "proxy"
  secure_json_data_encoded = jsonencode({
    password = data.vault_generic_secret.grafana.data["password"]
  })
  json_data_encoded = jsonencode({
    database        = local.database.name
    sslmode         = "disable"
    postgresVersion = 1510
    tlsAuth         = false
  })
}
