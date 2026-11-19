job "nomad-canary-demo" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 2

    network {
      port "http" {
        to = 8080
      }
    }

    update {
      max_parallel     = 1
      canary           = 1
      min_healthy_time = "10s"
      healthy_deadline = "3m"
      auto_promote     = true
      auto_revert      = true
    }

    service {
      name         = "nomad-canary-demo"
      port         = "http"
      address_mode = "host"

      check {
        name     = "http-health"
        type     = "http"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
      }
    }

    task "api" {
      driver = "docker"

      config {
        image = "ghcr.io/wandile-lab/nomad-canary-demo:latest"
        ports = ["http"]
      }

      env {
        APP_VERSION = "v1.0.0"
        FAIL_HEALTH = "false"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
