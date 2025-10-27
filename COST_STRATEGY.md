# COST_STRATEGY

Goal: Keep overall spend <= $10 USD by using free tiers and simulation-first approaches.

Principles
- Default to local/simulated resources. Avoid creating real cloud compute unless explicitly requested.
- Use Terraform only for plan/graph generation by default — do not run `apply` against real cloud accounts.
- Use free-hosting for UI if needed (Streamlit Community Cloud, Vercel, GitHub Pages) but prefer local runs for demos.
- All demo flows that would otherwise create cloud resources will instead produce Terraform changes in branches and stay in "plan" state. The GitOps pipeline will be configured to require manual approval before any `apply` step.

Budget targets
- Development & demo: $0 (fully local/simulated)
- Optional live deployment (if requested): cap $10; use smallest free-tier instances and strict destroy-on-complete steps.

Safe defaults
- Terraform workflows run `plan` only on CI; `apply` is only available behind a manual approval step and documented cost estimate.
- Infrastructure modules include a `simulate = true` variable that causes modules to create no-op resources or local Docker containers instead of cloud resources.

If you want a live multi-cloud apply later, we will enumerate required resources and provide a cost estimate before enabling `apply` in CI.
