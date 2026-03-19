# infra-cloud-demo

> Spring Boot 3 + Java 21 API demonstrating modern cloud infrastructure practices.

[![CI](https://github.com/tharsis-soares/infra-cloud/actions/workflows/ci.yml/badge.svg)](https://github.com/tharsis-soares/infra-cloud/actions/workflows/ci.yml)
[![CD](https://github.com/tharsis-soares/infra-cloud/actions/workflows/cd.yml/badge.svg)](https://github.com/tharsis-soares/infra-cloud/actions/workflows/cd.yml)

## Stack

- **Runtime:** Java 21 + Spring Boot 4
- **Container:** Docker multi-stage build (Alpine JRE — 93MB final image)
- **Orchestration:** Kubernetes (Deployment, Service, Ingress, HPA, ConfigMap)
- **IaC:** Terraform → GCP Cloud Run + Artifact Registry
- **CI/CD:** GitHub Actions (CI on PR, CD on merge to main)
- **Cloud:** GCP (Cloud Run, Artifact Registry) + OCI (Docker Compose)

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /hello` | Returns greeting with version |
| `GET /actuator/health` | Full health check (liveness + readiness) |

## Running locally
```bash
# With Maven
./mvnw spring-boot:run

# With Docker
docker build -t infra-demo:v1 .
docker run -p 8080:8080 infra-demo:v1

# With Docker Compose
docker compose up -d
```

## Infrastructure

### Kubernetes
```bash
kubectl apply -f k8s/
kubectl get pods,svc,ingress,hpa
```

### Terraform (GCP)
```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Project Structure
infra-cloud/
├── src/                        # Spring Boot application
├── k8s/                        # Kubernetes manifests
│   ├── configmap.yml
│   ├── deployment.yml
│   ├── service.yml
│   ├── ingress.yml
│   └── hpa.yml
├── terraform/                  # IaC — GCP Cloud Run
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── environments/
│       ├── dev/terraform.tfvars
│       └── prod/terraform.tfvars
├── .github/workflows/          # CI/CD pipelines
│   ├── ci.yml                  # Build + test on every PR
│   └── cd.yml                  # Deploy to GCP on merge to main
├── Dockerfile                  # Multi-stage build
└── docker-compose.yml          # Local/OCI deployment