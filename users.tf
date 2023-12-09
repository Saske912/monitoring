locals {
  users = toset(flatten([
    for team, data in local.teams : [
      data.users
    ]
  ]))
}
data "gitlab_user" "user" {
  for_each = local.users
  username = each.value
}

resource "grafana_user" "user" {
  for_each = local.users
  email    = "${each.value}@facecast.net"
  password = local.grafana["ADMIN_PASSWORD"]
  login    = data.gitlab_user.user[each.value].username
  name     = data.gitlab_user.user[each.value].name
}
