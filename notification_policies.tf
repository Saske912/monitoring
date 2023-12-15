resource "grafana_notification_policy" "policy" {
  group_by      = ["..."]
  contact_point = grafana_contact_point.email.name

  group_wait      = "45s"
  group_interval  = "6m"
  repeat_interval = "3h"
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
    group_wait = "35s"
    # group_interval  = "5m"
    # repeat_interval = "30m"
    group_interval  = "10s"
    repeat_interval = "30s"
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
    repeat_interval = "5m"
    contact_point   = grafana_contact_point.telegram.name
    group_by        = ["critical"]
  }
}
