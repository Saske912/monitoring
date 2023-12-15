resource "grafana_message_template" "email-template" {
  name     = "email шаблон"
  template = <<EOT
{{- define "email.message_alert" -}}
{{- range .Labels.SortedPairs }}{{ .Name }}={{ .Value }} {{ end }} имеет значение
{{- range $k, $v := .Values }} {{ $k }}={{ $v }}{{ end }}
{{- end -}}

{{ define "email.message" }}
Есть {{ len .Alerts.Firing }} уведомлений о проблемах в системе, и {{ len .Alerts.Resolved }} решённых вопросов

{{ if .Alerts.Firing -}}
Уведомления о ошибках:
{{- range .Alerts.Firing }}
- {{ template "email.message_alert" . }}
{{- end }}
{{- end }}

{{ if .Alerts.Resolved -}}
Решённые значения:
{{- range .Alerts.Resolved }}
- {{ template "email.message_alert" . }}
{{- end }}
{{- end }}

{{ end }}
EOT
}

resource "grafana_message_template" "telegram-template" {
  name     = "telegram шаблон"
  template = <<EOT
**АЛЕРТ: {alertname}**
**Описание:** {description}
**Тип:** {severity}

**Метки:**
- *Контейнер:* {container}
- *Экземпляр:* {instance}
- *Под: *{pod}
- *Сервис:* {service}

**Аннотации:**
- *Краткое описание:* {summary}

[Ссылка на дашборд](<{dashboard}>) | [Ссылка на панель](<{panel}>) | [Управление уведомлениями](<{silence}>)
EOT
}
