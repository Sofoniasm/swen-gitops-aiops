# GitOps CI: Terraform workflows and safety

This repository includes two GitHub Actions workflows to support safe GitOps-style infrastructure changes:

- `.github/workflows/terraform-plan.yml` — runs on pull requests and performs `terraform init` + `terraform plan` against the `infra/` folder with `simulate=true`. The generated plan is uploaded as an artifact.

- `.github/workflows/terraform-apply.yml` — a manual `workflow_dispatch` action that runs `terraform apply` with `simulate=false`. For safety this job targets a protected GitHub environment named `production` so you can require reviewers/approvals before it runs.

Before using the manual apply workflow, configure the following in your repository settings:

1. Repository Secrets (Settings → Secrets):
   - `AWS_ACCESS_KEY_ID` — an AWS key with limited, audited permissions for the demo (rotate after use).
   - `AWS_SECRET_ACCESS_KEY` — the secret for the above key.
   - `AWS_REGION` — the target region for the demo (e.g. `us-east-1`).

2. Protected Environment (Settings → Environments):
   - Create an environment named `production` and add required reviewers or protection rules so that `terraform-apply.yml` cannot run without explicit approval.

Safety checklist before any real apply:

- Inspect the plan artifact from the PR workflow before running an apply.
- Use least-privilege AWS credentials and rotate/delete them after the demo.
- Keep `simulate=true` as the default for PRs to avoid accidental resource creation.

Local run guidance (short):

- Initialize: `terraform -chdir=infra init`
- Plan (simulation): `terraform -chdir=infra plan -var='simulate=true' -out=plan.tfplan`
- Plan (real): `terraform -chdir=infra plan -var='simulate=false' -out=plan.tfplan` (inspect carefully)
- Apply (real): `terraform -chdir=infra apply plan.tfplan`

If you want me to add a GitHub Actions job that automatically posts the plan summary to PR comments, tell me and I’ll add it next.
