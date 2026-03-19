terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend remoto — descomenta quando tiver GCP configurado
  # backend "gcs" {
  #   bucket = "infra-demo-tfstate"
  #   prefix = "prod/state"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ── Artifact Registry ────────────────────────────────────────
resource "google_artifact_registry_repository" "infra_demo" {
  location      = var.region
  repository_id = "infra-demo"
  description   = "Docker repository for infra-demo"
  format        = "DOCKER"
}

# ── Cloud Run Service ────────────────────────────────────────
resource "google_cloud_run_v2_service" "infra_demo" {
  name     = "infra-demo"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      ports {
        container_port = 8080
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "prod"
      }

      env {
        name  = "APP_VERSION"
        value = var.app_version
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle = true # só usa CPU quando processando request
      }

      liveness_probe {
        http_get {
          path = "/actuator/health/liveness"
          port = 8080
        }
        initial_delay_seconds = 30
        period_seconds        = 15
      }

      startup_probe {
        http_get {
          path = "/actuator/health/readiness"
          port = 8080
        }
        initial_delay_seconds = 20
        period_seconds        = 10
        failure_threshold     = 3
      }
    }
  }

  depends_on = [google_artifact_registry_repository.infra_demo]
}

# ── IAM — acesso público ao Cloud Run ───────────────────────
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.infra_demo.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}