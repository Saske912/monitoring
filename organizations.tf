resource "grafana_organization" "orgranization" {
  for_each     = var.organizations
  name         = each.key
  admin_user   = var.alert_email
  create_users = false
}

resource "grafana_organization_preferences" "orgranization_preferences" {
  for_each   = var.organizations
  timezone   = "browser"
  week_start = "Monday"
  org_id     = grafana_organization.orgranization[each.key].id
}
