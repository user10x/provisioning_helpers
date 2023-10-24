# define variables
variable "project_id" {
  type        = string
  description = "The project name to use."
  default = "project_id"
}

variable "project_number" {
  type        = string
  description = "The project number to use."
  default = "bc-nonprod-roc-1a1c"
}


resource "google_service_account" "sa-name" {
  account_id = "oc-test-sa"
  display_name = "oc-test-sa"
  project = var.project_id
}



resource "google_project_iam_member" "oc-firestore_owner_binding" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${google_service_account.sa-name.email}"
}

variable "region" {
  type        = string
  description = "The region where resources are created."
  default = "us-west2"
}

variable "cloud_scheduler_service_account_email" {
  type        = string
  description = "The service account email."
  default = "CLOUD_SCHEDULER_SERVICE_ACCOUNT_EMAIL"
}

variable "batch_service_account_email" {
  type        = string
  description = "The service account email."
  default = "BATCH_SERVICE_ACCOUNT_EMAIL"
}

resource "google_cloud_run_service" "my_service" {
  name     = "oc-appx-run-service"
  location = var.region
  project = var.project_id

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }

  }


  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_service_account" "scheduler-sa" {
  account_id   = "app-scheduler-appx"
  project      = var.project_id
  display_name = "appx Scheduler Service Account"
}

resource "google_project_iam_member" "schedular_invoker_binding" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler-sa.email}"
}


resource "google_cloud_scheduler_job" "http_post_job" {
  name     = "oc-sample-http-post-job"
  schedule = "*/5 * * * *"  # Cron schedule for running the job every 5 minutes
  project = var.project_id
  region  = var.region

  http_target {
    uri                  = google_cloud_run_service.my_service.status[0].url
#    uri = "https://oc-autorobo-sf-alerts-vomsqo5wia-wl.a.run.app"
    http_method          = "POST"
    oidc_token {
      service_account_email =  google_service_account.scheduler-sa.email
    }
  }
}




output "scheduler_service_account_email" {
  value = google_service_account.scheduler-sa.email
}

output "service_account_email" {
  value = google_service_account.sa-name.email
}

output "service_url" {
  value = google_cloud_run_service.my_service.status[0].url
}