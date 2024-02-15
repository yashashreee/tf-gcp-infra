# Your Terraform Configuration

This repository contains Terraform configuration for setting up Google Cloud Platform networking.

## Usage

- Ensure you have the necessary credentials and variables set.
- Run `terraform init` to initialize your Terraform environment.
- Run `terraform apply -var-file=terraform.tfvars -var-file=environments/demo/terraform.tfvars` to apply the configuration for demo environment.
- Run `terraform apply -var-file=terraform.tfvars -var-file=environments/dev/terraform.tfvars` to apply the configuration for dev environment.

## Structure

- `dev/variables.tf`: Variables specific to the development environment.
- `demo/variables.tf`: Variables specific to the demo environment.
- Other configuration files for providers, versions, etc.
