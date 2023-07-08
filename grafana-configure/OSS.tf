data "vault_generic_secret" "influx" {
  path = "kv/influxdb"
}
locals {
  influxdb = data.vault_generic_secret.influx.data
}


resource "grafana_data_source" "inflxudb" {
  type        = "influxdb"
  name        = "influxDBv2"
  url         = "http://influxdb.metrics:8086"
  access_mode = "proxy"
  json_data_encoded = jsonencode({
    version       = "Flux"
    orgranization = local.influxdb["organization"]
    defaultBucket = local.influxdb["bucket"]
    token         = local.influxdb["token"]
  })
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  url        = "http://prometheus-server.prometheus"
  is_default = true
}
