# Your Terraform Configuration

This repository contains Terraform configuration for setting up Google Cloud Platform networking.

## GCP Service APIs

Enable following APIs in GCP:
- IAM Service Account Credentials API
- Compute Engine API 

## Usage

- Ensure you have the necessary credentials and variables set.
- Run `terraform init` to initialize your Terraform environment.
- Run `terraform apply -var-file=terraform.tfvars` to apply the configuration

## Structure

- `dev/variables.tf`: Variables specific to the development environment.
- `demo/variables.tf`: Variables specific to the demo environment.
- Other configuration files for providers, versions, etc.
