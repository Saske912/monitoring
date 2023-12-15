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
    message = <<EOT
{{ if len .Alerts.Firing }}
  <b>{{ len .Alerts.Firing }} активных уведомлений о ошибках</b>
  {{ range .Alerts }}
  <b>{{ index .Labels "alertname" }}</b> 🕙 {{ .StartsAt.Format "15:04:05    🗓️ 2006-01-02" }}

    {{ if index .Annotations "description" }}
  <i>описание инцидента: </i> {{ index .Annotations "description" }}
    {{ end }}
    
    {{ if gt (len .GeneratorURL) 0 }}<a href="{{ .GeneratorURL }}">алерт</a>  |  {{ end }}
    {{- if gt (len .SilenceURL) 0 }}<a href="{{ .SilenceURL }}">🔕 мут</a>  |  {{ end }}
    {{- if gt (len .DashboardURL) 0 }}📁 <a href="{{ .DashboardURL }}">дашборд</a>  |  {{ end }}
    {{- if gt (len .PanelURL) 0 }}<a href="{{ .PanelURL }}">панель</a> {{- end -}}
  {{ end }}
{{ else }}
  Ну что же нет тут ничегошеньки.
{{ end }}
EOT
  }
}
