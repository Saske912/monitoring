resource "grafana_rule_group" "systemAlerts" {
  name             = "systemAlerts"
  folder_uid       = grafana_folder.folder.uid
  org_id           = 1
  interval_seconds = 60
  rule {
    name      = "CPU and Memory Load Alert"
    condition = "C"
    for       = "0s"
    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = data.grafana_data_source.prometheus.uid
      model = jsonencode({
        intervalMs    = 10000,
        maxDataPoints = 4320,
        refId         = "A",
        targets = [
          {
            expr         = "100 - avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) by (node) * 100",
            legendFormat = "CPU Load"
          },
          {
            expr         = "100 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100",
            legendFormat = "Memory Load"
          }
        ]
      })
    }

    data {
      datasource_uid = "__expr__"
      model          = <<EOT
        {
          "conditions": [
            {
              "evaluator": {"type": "gt", "params": [90]},
              "operator": {"type": "or"},
              "query": {"params": ["A"], "type": "query"},
              "reducer": {"type": "avg", "params": []},
              "type": "query"
            }
          ],
          "datasource": {"name": "Expression","type": "__expr__","uid": "__expr__"},
          "expression": "A",
          "hide": false,
          "intervalMs": 10000,
          "maxDataPoints": 4320,
          "reducer": "avg",
          "refId": "B",
          "type": "reduce"
        }
      EOT
      ref_id         = "B"
      relative_time_range {
        from = 600
        to   = 0
      }
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 600
        to   = 0
      }
      model = jsonencode({
        expression = "$B > 70",
        type       = "math",
        refId      = "C"
      })
    }
  }
}
