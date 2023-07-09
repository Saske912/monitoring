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
