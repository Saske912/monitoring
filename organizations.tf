# resource "grafana_organization" "organization" {
#   for_each     = var.organizations
#   name         = each.key
#   create_users = false
#   admins       = ["admin@localhost"]
# }

# resource "grafana_organization_preferences" "organization_preferences" {
#   for_each   = var.organizations
#   timezone   = "browser"
#   week_start = "Monday"
#   org_id     = grafana_organization.organization[each.key].id
# }
