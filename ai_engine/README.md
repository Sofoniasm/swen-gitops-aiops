AI Engine Simulator

This folder contains a simple telemetry and decision simulator used to drive the backend and dashboard during development.

Usage
- HTTP mode (posts to running backend at http://127.0.0.1:8000):
  python ai_engine/simulator.py --mode http --service fetcher --interval 5

- In-process mode (calls backend functions directly; useful when the server isn't running):
  python ai_engine/simulator.py --mode inproc --service fetcher --interval 5

The simulator emits a telemetry JSON and a decision JSON every `interval` seconds. The decision uses a small rule-based model and includes a `confidence` and `reason` field.
