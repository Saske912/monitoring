data "vault_generic_secret" "postgresql" {
  path = "kv/postgres"
}

locals {
  postgres = data.vault_generic_secret.postgresql.data
}

data "vault_generic_secret" "grafana" {
  path = "kv/grafana"
}

provider "postgresql" {
  host            = local.postgres["load-balancer-ip"]
  port            = 5432
  database        = local.postgres["database"]
  username        = local.postgres["admin"]
  password        = local.postgres["admin-password"]
  sslmode         = "disable"
  connect_timeout = 15
}

resource "postgresql_role" "grafana" {
  name     = data.vault_generic_secret.grafana.data["username"]
  login    = true
  password = data.vault_generic_secret.grafana.data["password"]
  roles    = ["pg_read_all_data"]
  inherit  = false
}
