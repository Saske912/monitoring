resource "grafana_dashboard" "dashboard" {
  config_json = jsonencode({
    title = "CPU Metrics"
    style = "dark"
    panels = [
      {
        id = 1
        gridPos = {
          h = 8
          w = 16
          x = 4
          y = 0
        }
        type       = "graph"
        title      = "нагрузка на CPU"
        datasource = data.grafana_data_source.prometheus.name
        targets = [
          {
            expr         = "100 - avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) by (node) * 100"
            legendFormat = "{{ node }}"
          }
        ]
        renderer = "flot"
        xaxis = {
          show = true
        }
        yaxes = [
          {
            format  = "percent"
            label   = "нагрузка на CPU"
            logBase = 1
            max     = "100"
            min     = "0"
            show    = true
          },
          {
            format  = "short"
            label   = "Time"
            logBase = 1
            max     = null
            min     = null
            show    = true
          }
        ]
        legend = {
          avg     = false
          current = false
          max     = false
          min     = false
          show    = true
          total   = false
          values  = false
        }
        timeFrom  = null
        timeShift = null
        tooltip = {
          shared     = true
          sort       = 0
          value_type = "individual"
        }
        aliasColors     = {}
        seriesOverrides = []
      },
      {
        id = 2
        gridPos = {
          h = 8
          w = 16
          x = 4
          y = 0
        }
        type       = "graph"
        title      = "Хранилище"
        datasource = data.grafana_data_source.prometheus.name
        targets = [
          {
            expr         = "sum by(node) (node_filesystem_size_bytes{fstype!=\"\"} - node_filesystem_avail_bytes{fstype!=\"\"}) / sum by(node) (node_filesystem_size_bytes{fstype!=\"\"}) * 100"
            legendFormat = "{{ node }}"
          }
        ]
        renderer = "flot"
        xaxis = {
          show = true
        }
        yaxes = [
          {
            format  = "percent"
            label   = "Использование Хранилища"
            logBase = 1
            max     = "100"
            min     = "0"
            show    = true
          },
          {
            format  = "short"
            label   = "Time"
            logBase = 1
            max     = null
            min     = null
            show    = true
          }
        ]
        legend = {
          avg     = false
          current = false
          max     = false
          min     = false
          show    = true
          total   = false
          values  = false
        }
        timeFrom  = null
        timeShift = null
        tooltip = {
          shared     = true
          sort       = 0
          value_type = "individual"
        }
        aliasColors     = {}
        seriesOverrides = []
      },
      {
        id = 3
        gridPos = {
          h = 8
          w = 16
          x = 4
          y = 0
        }
        type       = "graph"
        title      = "оперативная память"
        datasource = data.grafana_data_source.prometheus.name
        targets = [
          {
            expr         = "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100"
            legendFormat = "{{ node }}"
          }
        ]
        renderer = "flot"
        xaxis = {
          show = true
        }
        yaxes = [
          {
            format  = "percent"
            label   = "использование"
            logBase = 1
            max     = "100"
            min     = "0"
            show    = true
          },
          {
            format  = "short"
            label   = "Time"
            logBase = 1
            max     = null
            min     = null
            show    = true
          }
        ]
        legend = {
          avg     = false
          current = false
          max     = false
          min     = false
          show    = true
          total   = false
          values  = false
        }
        timeFrom  = null
        timeShift = null
        tooltip = {
          shared     = true
          sort       = 0
          value_type = "individual"
        }
        aliasColors     = {}
        seriesOverrides = []
      }
    ]
    annotations = {
      list = []
    }
    refresh       = "5s"
    schemaVersion = 21
    version       = 0
  })
}

resource "grafana_dashboard" "postgres" {
  folder = grafana_folder.folder.id
  config_json = jsonencode({
    title = "Базы данных"
    style = "dark"
    panels = [
      {
        type       = "table"
        title      = "активные подключения к PostgreSQL"
        datasource = grafana_data_source.postgresql.name
        gridPos = {
          w = 8
          h = 7
          x = 6
          y = 7
        }
        targets = [
          {
            rawQuery = true
            format   = "table"
            alias    = "connections"
            rawSql   = <<EOT
SELECT datname AS база, count(*) AS количество
FROM pg_stat_activity
WHERE state = 'active'
GROUP BY datname;
EOT
          }
        ]
      },
    ]
  })
}
