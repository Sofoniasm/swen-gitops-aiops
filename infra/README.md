Infra (simulation-first)
=========================

This folder contains a small Terraform skeleton used for the SWEN prototype. It's simulation-first: modules default to `simulate = true` so they create no real cloud resources.

How to use (local/demo):

- Install Terraform (optional for plan generation): https://www.terraform.io
- Run `terraform init` in `infra/` to initialize providers and modules (no cloud apply will be performed by default).
- Run `terraform plan -var='simulate=true'` to see a plan that uses `null_resource` to simulate infrastructure.

If you later want to enable real providers, set `simulate = false` and update provider blocks in `main.tf`. Do not run `apply` without reviewing cost estimates and enabling CI manual approvals.
