output "cloud_run_url" {
  description = "URL pública do Cloud Run"
  value       = google_cloud_run_v2_service.infra_demo.uri
}

output "artifact_registry_url" {
  description = "URL do Artifact Registry"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/infra-demo"
}
