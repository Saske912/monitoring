
provider "grafana" {
  url  = "https://${data.vault_generic_secret.graf.data["domain"]}"
  auth = "${data.vault_generic_secret.graf.data["username"]}:${data.vault_generic_secret.graf.data["password"]}"
}
locals {
  telegram_bot = jsondecode(data.vault_generic_secret.kolve.data["telegramBot"])
}

resource "grafana_contact_point" "telegram" {
  name = "telegram"
  telegram {
    chat_id = local.telegram_bot.chatID
    token   = local.telegram_bot.token
  }
  depends_on = [helm_release.grafana]
}

data "vault_generic_secret" "mihail" {
  path = "kv/mihail"
}

resource "grafana_message_template" "email-template" {
  name       = "email шаблон"
  template   = <<EOT
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
  depends_on = [helm_release.grafana]
}

resource "grafana_contact_point" "email" {
  depends_on = [helm_release.grafana]
  name       = "email"
  email {
    addresses               = [data.vault_generic_secret.mihail.data["email"]]
    message                 = "{{ len .Alerts.Firing }} важных уведомлений."
    subject                 = "{{ template \"default.title\" .}}"
    single_email            = true
    disable_resolve_message = false
    # template = grafa
  }
}

resource "grafana_mute_timing" "warnings" {
  depends_on = [helm_release.grafana]
  name       = "warnings"
  intervals {
    times {
      start = "18:00"
      end   = "10:00"
    }
    weekdays = ["sunday", "saturday"]
  }
}

resource "grafana_mute_timing" "errors" {
  depends_on = [helm_release.grafana]
  name       = "errors"
  intervals {
    times {
      start = "22:00"
      end   = "08:00"
    }
  }
}

resource "grafana_notification_policy" "policy" {
  depends_on    = [helm_release.grafana]
  group_by      = ["..."]
  contact_point = grafana_contact_point.email.name

  group_wait      = "45s"
  group_interval  = "6m"
  repeat_interval = "5h"
  policy {
    matcher {
      label = "warning"
      match = "="
      value = "true"
    }
    group_by      = ["warning"]
    continue      = true
    mute_timings  = [grafana_mute_timing.warnings.name]
    contact_point = grafana_contact_point.email.name
  }
  policy {
    matcher {
      label = "error"
      match = "="
      value = "true"
    }
    group_wait      = "35s"
    group_interval  = "5m"
    repeat_interval = "3h"
    contact_point   = grafana_contact_point.telegram.name
    mute_timings    = [grafana_mute_timing.errors.name]
    group_by        = ["error"]
  }
  policy {
    matcher {
      label = "critical"
      match = "="
      value = "true"
    }
    group_wait      = "10s"
    group_interval  = "1m"
    repeat_interval = "1h"
    contact_point   = grafana_contact_point.telegram.name
    group_by        = ["critical"]
  }
}
