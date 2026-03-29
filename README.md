# Task 04: Azure Infrastructure as Code with Terraform

![Terraform](https://img.shields.io/badge/Terraform-1.x-844FBA?logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Cloud-Microsoft%20Azure-0078D4?logo=microsoftazure&logoColor=white)
![IaC Exercise](https://img.shields.io/badge/Type-Infrastructure%20as%20Code-0A7E8C)

Provision a complete Azure environment for a .NET web application using Terraform and GitHub Actions.

This project creates and configures:
- Azure Resource Group
- Azure App Service Plan (Linux, F1)
- Azure Linux Web App (.NET 6)
- Azure SQL Server and SQL Database
- SQL firewall rule
- App Service source control integration to a GitHub repository
- Remote Terraform state backend in Azure Storage

## Why This Project Is Useful

- Demonstrates a full Infrastructure as Code workflow on Azure.
- Uses remote Terraform state for safer collaboration.
- Shows CI/CD-style Terraform automation with GitHub Actions:
  - bootstrap backend
  - test (fmt + validate)
  - plan + apply
- Automatically generates unique resource names using a random suffix to reduce naming collisions.

## Project Structure

- `main.tf`: provider, backend, and all Azure resources
- `variables.tf`: input variable definitions
- `terraform.tfvars`: non-sensitive default values for this exercise
- `task04.txt`: manual Azure bootstrap/reference commands
- `.github/workflows/bootstrap.yml`: creates backend resource group, storage account, and container
- `.github/workflows/test.yml`: runs Terraform checks on push to `main`
- `.github/workflows/apply.yml`: runs plan and apply after successful tests

## How To Get Started

### Prerequisites

- Terraform (1.x recommended)
- Azure CLI (`az`)
- An Azure subscription
- A GitHub repository with Actions enabled

### 1) Clone and enter the project

```bash
git clone <your-repo-url>
cd task04
```

### 2) Prepare credentials and variables

Create or export values for sensitive inputs:
- `sql_admin_username`
- `sql_admin_password`
- `azure_subscription_id`

You can provide them either:
- in environment variables (`TF_VAR_*`), or
- in a local, ignored tfvars file (recommended for local-only usage)

Example (PowerShell):

```powershell
$env:TF_VAR_sql_admin_username = "<sql-admin-user>"
$env:TF_VAR_sql_admin_password = "<strong-password>"
$env:TF_VAR_azure_subscription_id = "<subscription-id>"
```

Then sign in:

```bash
az login
```

### 3) Initialize and validate Terraform

```bash
terraform init
terraform fmt -check -recursive
terraform validate
```

### 4) Plan and apply

```bash
terraform plan -out tfplan
terraform apply tfplan
```

### 5) Destroy resources (when finished)

```bash
terraform destroy
```

Note: `azurerm_mssql_database` has `prevent_destroy = true` in `main.tf`. You must remove or override that lifecycle setting before a full destroy can succeed.

## GitHub Actions Setup

The workflows rely on repository secrets.

Required secrets:
- `AZURE_CREDENTIALS` (JSON output from `az ad sp create-for-rbac --sdk-auth`)
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `TF_VAR_sql_admin_username`
- `TF_VAR_sql_admin_password`
- `TF_VAR_azure_subscription_id`

Recommended execution order:
1. Run `.github/workflows/bootstrap.yml` once (manual dispatch) to create backend storage.
2. Push to `main` to trigger `.github/workflows/test.yml`.
3. After test success, `.github/workflows/apply.yml` runs plan and apply.

## Usage Notes

- Remote backend values are hard-coded in `main.tf`.
- Resource names are generated from values in `terraform.tfvars` plus a random 5-digit suffix.
- The web app gets an SQL connection string from created SQL resources.
- Source control integration is configured via `github_repo_url`.

## Where To Get Help

- Review the Terraform files:
  - `main.tf`
  - `variables.tf`
  - `terraform.tfvars`
- Review workflow definitions:
  - `.github/workflows/bootstrap.yml`
  - `.github/workflows/test.yml`
  - `.github/workflows/apply.yml`
- Review bootstrap command reference: `task04.txt`
- Official docs:
  - Terraform AzureRM Provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
  - Terraform CLI: https://developer.hashicorp.com/terraform/cli
  - Azure CLI: https://learn.microsoft.com/cli/azure/

## Maintainers And Contributions

Maintainer:
- Repository owner (GitHub user from configured repo URL): `ttsaryanski`

Contributions are welcome.

Minimal contribution flow:
1. Create a feature branch.
2. Run local checks: `terraform fmt -check -recursive` and `terraform validate`.
3. Open a pull request with a clear summary of infrastructure changes.
4. Ensure workflows pass before merging.

## Security And Sensitive Data

- Do not commit secrets, service-principal credentials, SQL passwords, or local state backups.
- Keep secret values in GitHub Secrets and/or secure local environment variables.
- Rotate credentials if they were ever committed accidentally.
