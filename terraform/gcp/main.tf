# define variables
variable "project_id" {
  type        = string
  description = "The project name to use."
  default = "PROJECT_ID"
}

variable "project_number" {
  type        = string
  description = "The project number to use."
  default = "PROJECT_NUMBER"
}

variable "region" {
  type        = string
  description = "The region where resources are created."
  default = "us-central1"
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

# define a Cloud Scheduler cron job which triggers Batch jobs
resource "google_cloud_scheduler_job" "batch-job-invoker" {
  paused           = false # this cron job is enabled
  name             = "batch-job-invoker"
  project          = var.project_id
  region           = var.region
  schedule         = "*/5 * * * *" # when enabled, run every 5 minutes
  time_zone        = "America/Los_Angeles"
  attempt_deadline = "180s"

  retry_config {
    max_doublings        = 5
    max_retry_duration   = "0s"
    max_backoff_duration = "3600s"
    min_backoff_duration = "5s"
  }

  # when this cron job runs, create and run a Batch job
  http_target {
    http_method = "POST"
    uri = "https://batch.googleapis.com/v1/projects/${var.project_number}/locations/${var.region}/jobs"
    headers = {
      "Content-Type" = "application/json"
      "User-Agent"   = "Google-Cloud-Scheduler"
    }
    # Batch job definition
    body = base64encode(<<EOT
    {
      "taskGroups":[
        {
          "taskSpec": {
            "runnables":{
              "script": {
                "text": "echo Hello world! This job was created using Terraform and Cloud Scheduler."
              }
            }
          }
        }
      ],
      "allocationPolicy": {
        "serviceAccount": {
          "email": "${var.batch_service_account_email}"
        }
      },
      "labels": {
        "source": "terraform_and_cloud_scheduler_tutorial"
      },
      "logsPolicy": {
        "destination": "CLOUD_LOGGING"
      }
    }
    EOT
    )
    oauth_token {
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = var.cloud_scheduler_service_account_email
    }
  }
}
