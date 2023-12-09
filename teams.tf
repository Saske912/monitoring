locals {
  teams = merge([
    for org, org_data in var.organizations : {
      for team, users in org_data.teams :
      "${org}-${team}" => {
        org   = org
        users = users
      }
    }
  ]...)
}

resource "grafana_team" "team" {
  depends_on = [grafana_user.user]
  for_each   = local.teams
  name       = each.key
  members    = [for each in each.value.users : "${each}@facecast.net"]
  preferences {
    timezone = "browser"
  }
}
