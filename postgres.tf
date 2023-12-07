# resource "postgresql_role" "grafana" {
#   name     = local.grafana["ADMIN_USER"]
#   login    = true
#   password = local.grafana["ADMIN_PASSWORD"]
#   roles    = ["pg_read_all_data"]
#   inherit  = false
# }


resource "postgresql_role" "grafana" {
  name     = "grafana-metrics"
  login    = true
  password = local.grafana["ADMIN_PASSWORD"]
}

resource "postgresql_grant" "readonly_database_facecast" {
  database    = var.postgresql_database_metrics_target
  role        = postgresql_role.mertics.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT"]
}