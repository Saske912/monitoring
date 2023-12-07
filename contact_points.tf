resource "grafana_contact_point" "email" {
  name = "email"
  email {
    addresses               = [var.alert_email]
    message                 = "{{ len .Alerts.Firing }} важных уведомлений."
    subject                 = "{{ template \"default.title\" .}}"
    single_email            = true
    disable_resolve_message = false
  }
}

resource "grafana_contact_point" "telegram" {
  name = "telegram"
  telegram {
    chat_id = var.telegram_bot.chat_id
    token   = var.telegram_bot.token
  }
}
