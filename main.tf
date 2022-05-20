terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.21.0"
    }
  }
}

provider "google" {
  project = "douter"
}

provider "google-beta" {
  project = "douter"
}

# Cloud storage
resource "google_storage_bucket" "website_bucket" {
  name          = "douter-website-bucket"
  location      = "ASIA"
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  website {
    main_page_suffix = "index.html"
  }
  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_storage_bucket.website_bucket.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

# Artifact registry
resource "google_project_service" "artifact_registry" {
  service = "artifactregistry.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_artifact_registry_repository" "backend_user" {
  provider = google-beta
  
  location = "asia-east1"
  repository_id = "backend-user"
  format = "DOCKER"
  depends_on = [google_project_service.artifact_registry]
}