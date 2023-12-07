resource "grafana_mute_timing" "warnings" {
  name = "warnings"
  intervals {
    times {
      start = "18:00"
      end   = "23:59"
    }
    times {
      start = "00:00"
      end   = "10:00"
    }
    weekdays = ["sunday", "saturday"]
  }
}

resource "grafana_mute_timing" "errors" {
  name = "errors"
  intervals {
    times {
      start = "22:00"
      end   = "23:59"
    }
    times {
      start = "00:00"
      end   = "08:00"
    }
  }
}
