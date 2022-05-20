terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.21.0"
    }
  }
}

provider "google" {
  credentials = file("gcp-key.json")
  project = "cancy-329206"
}

# Cloud storage
data "google_iam_policy" "viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "allUsers",
    ] 
  }
}

resource "google_storage_bucket" "website_bucket" {
  name          = "website-bucket"
  location      = "ASIA"
  force_destroy = true
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

resource "google_storage_bucket_iam_policy" "viewer" {
  bucket = google_storage_bucket.website_bucket.name
  policy_data = data.google_iam_policy.viewer.policy_data
}

# Artifact registry
resource "google_artifact_registry_repository" "user" {
  provider = google-beta

  location = "asia-east1"
  repository_id = "backend-user"
  format = "DOCKER"
}