variable "vault" {
  type = object({
    host  = string
    token = string
  })
}

variable "grafana_data_vault_path" {
  type = string
}

variable "redis_data_vault_path" {
  type = string
}

variable "postgresql_data_vault_path" {
  type = string
}

variable "postgresql_database_metrics_target" {
  type = string
}

variable "telegram_bot" {
  type = object({
    chat_id = string
    token   = string
  })
}

variable "alert_email" {
  type = string
}

variable "organizations" {
  type = map(object({
    teams = map(set(string))
  }))
}

variable "gitlab" {
  type = object({
    host  = string
    token = string
  })
}
