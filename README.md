# SWEN GitOps + AIOps Prototype

This repository contains a prototype for SWEN's GitOps + AIOps Cloud Intelligence Console. It focuses on a simulation-first approach so the entire demo can be run within free tiers or locally, keeping total spend below $10 USD.

Contents:
- infra/: Terraform modules (simulation-friendly)
- api/: AI engine and telemetry backend (FastAPI)
- dashboard/: Streamlit dashboard prototype
- ai_engine/: learning & decision logic
- docs/: architecture diagrams, POLICY.md, COST_STRATEGY.md, AI_LOG.md

Quick start (local, recommended to avoid cloud costs):
1. Create a Python virtualenv and install requirements in `api/requirements.txt` and `dashboard/requirements.txt`.
2. Run the backend: `python -m api.main` (FastAPI)
3. Run the dashboard: `streamlit run dashboard/streamlit_app.py`

See `COST_STRATEGY.md` for the cost-control strategy and `TELEMETRY_README.md` for telemetry details.
# swen-gitops-aiops
