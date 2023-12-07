provider "vault" {
  add_address_to_env = true
  address            = var.vault.host
  token              = var.vault.token
}

provider "grafana" {
  url  = "https://${local.grafana["HOST"]}"
  auth = "${local.grafana["ADMIN_USER"]}:${local.grafana["ADMIN_PASSWORD"]}"
}

provider "postgresql" {
  host            = local.postgres["HOST"]
  port            = 5432
  database        = "postgres"
  username        = "postgres"
  password        = local.postgres["INITIAL_ADMIN_PASSWORD"]
  sslmode         = "require"
  connect_timeout = 15
}
