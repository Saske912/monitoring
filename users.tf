locals {
  users = flatten([
    for team, data in local.teams : [
      data.users
    ]
  ])
}

data "gitlab_user" "user" {
  for_each = local.users
  username = each.value
}

resource "grafana_user" "user" {
  for_each = local.users
  id       = gitlab_user[each.value].id
  email    = "${each.value}@facecast.net"
  password = local.grafana["ADMIN_PASSWORD"]
  login    = gitlab_user[each.value].username
  name     = gitlab_user[each.value].name
}
