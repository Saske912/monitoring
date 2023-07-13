data "vault_generic_secret" "minio" {
  path = "kv/minio"
}

locals {
  minio = data.vault_generic_secret.minio.data
}

provider "minio" {
  // required
  minio_server     = local.minio["host"]
  minio_access_key = local.minio["key"]
  minio_secret_key = local.minio["secret_key"]

  // optional
  minio_region = local.minio["region"]
  minio_ssl    = false
}


# resource "minio_s3_bucket" "chunks" {
#   bucket = "chunks"
# }
# resource "minio_s3_bucket" "ruler" {
#   bucket = "ruler"
# }
# resource "minio_s3_bucket" "admin" {
#   bucket = "admin"
# }
