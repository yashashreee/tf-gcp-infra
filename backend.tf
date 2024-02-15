terraform {
  backend "gcs" {
    bucket = "webapp-cicd-tf-state"
    prefix = "static.tfstate.d"
    impersonate_service_account = "sa-webapp-tf-cicd@yash-cloud.iam.gserviceaccount.com"
  }
}
