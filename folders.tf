# resource "grafana_folder" "folder" {
#   title = data.vault_generic_secret.info.data["name"]
# }

# resource "grafana_folder_permission" "collectionPermission" {
#   folder_uid = grafana_folder.folder.uid
#   permissions {
#     role       = "Editor"
#     permission = "Edit"
#   }
#   permissions {
#     team_id    = grafana_team.team.id
#     permission = "View"
#   }
#   permissions {
#     user_id    = grafana_user.user.id
#     permission = "Admin"
#   }
# }