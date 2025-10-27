# TELEMETRY_README

This project uses simulated telemetry to feed the AI Ops engine and dashboard.

Telemetry sources (simulated):
- provider_costs: per-minute cost estimate per provider/region/instance type
- latency: simulated latency measurements between regions
- utilization: CPU/memory/network per service (simulated)

Data flow
1. Simulator (part of `ai_engine/`) emits periodic JSON telemetry to the backend API (FastAPI) over HTTP or WebSocket.
2. Backend stores recent telemetry in-memory and exposes WebSocket endpoints and REST endpoints for the dashboard.
3. AI engine consumes telemetry stream, evaluates routing decisions, and writes recommended Terraform variable changes to a branch in the repo (simulated commit in local run).
4. Dashboard subscribes to the telemetry and decision-stream and visualizes costs, latency, and commit history.

Refresh cadence
- Default: telemetry emitted every 5s (configurable)
- Dashboard updates via WebSocket in near real-time; fallback to polling every 5s.

Note: All telemetry is synthetic by default to avoid cloud costs; if you prefer, real telemetry can be integrated later (Prometheus exporters, cloud provider APIs) with cost considerations.
