locals {
  teams = merge([
    for org, org_data in var.organizations : {
      for team, users in org_data.teams :
      "${org}-${team}" => {
        org   = org
        users = users
      }
    }
  ])
}


resource "grafana_team" "team" {
  for_each = local.teams
  name     = each.key
  org_id   = grafana_organization.orgranization[each.value.org].id
  members  = [each.value.users]
  preferences {
    timezone = "browser"
  }
}
