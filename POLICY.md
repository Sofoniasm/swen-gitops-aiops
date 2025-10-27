# POLICY.md

This file describes policy rules used by the FinOps and GitOps flows.

Policy highlights
- Auto-approve Terraform applies where estimated monthly delta < $1 AND no region change.
- Require manual approval for any change where estimated monthly delta >= $1 OR region/provider change.
- All AI-generated changes are committed to an `ai-recommendation/*` branch and include an explanation and confidence score.
- A human reviewer must approve any `apply` produced by an `ai-recommendation` branch if the cost delta >= $0.50.

Policy enforcement
- CI pipeline evaluates cost delta using a local cost model and annotates PRs with policy decisions.
- Dashboard shows which recommendations were auto-approved and which were escalated.

More details will be added to a formal `POLICY.md` in `docs/` as policies are refined.
