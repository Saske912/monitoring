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
    tlsSkipVerify = true
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
  type = "Redis"
  name = "Redis"
  url  = "http://redis-headless.redis:6379"
  json_data_encoded = jsonencode({
    password = data.vault_generic_secret.redis.data["password"]
  })
}

data "vault_generic_secret" "postgresql" {
  path = "kv/postgres"
}

locals {
  postgres = data.vault_generic_secret.postgresql.data
}

provider "postgresql" {
  host            = local.postgres["load-balancer-ip"]
  port            = 5432
  database        = local.postgres["database"]
  username        = local.postgres["username"]
  password        = local.postgres["password"]
  sslmode         = "disable"
  connect_timeout = 15
}

resource "grafana_data_source" "postgresql" {
  type     = "postgres"
  name     = "PostgreSQL"
  url      = "http://${local.postgres["service"]}"
  username = local.postgres["username"]
  secure_json_data_encoded = jsonencode({
    password = local.database.password
  })
  json_data_encoded = jsonencode({
    database        = local.database.name
    sslmode         = "disable"
    postgresVersion = 1510
  })
}

data "vault_generic_secret" "users" {
  path = "kv/kolve/org/personal"
}

data "vault_generic_secret" "teams" {
  path = "kv/kolve/org/teams"
}

data "vault_generic_secret" "info" {
  path = "kv/kolve/org/info"
}

locals {
  mihail        = jsondecode(data.vault_generic_secret.users.data["mihail"])
  my-cat        = jsondecode(data.vault_generic_secret.users.data["my-cat"])
  spaceShifters = jsondecode(data.vault_generic_secret.teams.data["spaceShifters"])
}

resource "grafana_user" "user" {

  email    = local.mihail.email
  name     = local.mihail.name
  login    = local.mihail.login
  password = local.mihail.password
  is_admin = local.mihail.admin
}

resource "grafana_user" "cat" {

  email    = local.my-cat.email
  name     = local.my-cat.name
  login    = local.my-cat.login
  password = local.my-cat.password
  is_admin = local.my-cat.admin
}

resource "grafana_team" "team" {

  name    = "spaceShifters"
  members = local.spaceShifters
  preferences {
    timezone = "browser"
  }
}

resource "grafana_folder" "folder" {
  title = data.vault_generic_secret.info.data["name"]
}

resource "grafana_folder_permission" "collectionPermission" {
  folder_uid = grafana_folder.folder.uid
  permissions {
    role       = "Editor"
    permission = "Edit"
  }
  permissions {
    team_id    = grafana_team.team.id
    permission = "View"
  }
  permissions {
    user_id    = grafana_user.user.id
    permission = "Admin"
  }
}
