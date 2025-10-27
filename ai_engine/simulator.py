"""AI Ops telemetry simulator

This script can run in two modes:
- HTTP mode: posts telemetry and decisions to a running backend on http://127.0.0.1:8000
- inproc mode: imports the backend (api.main) and calls functions directly (useful for testing without a running server)

Usage:
    python ai_engine/simulator.py --mode http   # sends to HTTP backend
    python ai_engine/simulator.py --mode inproc # uses in-process API

The simulator emits telemetry periodically and runs a simple rule-based decision model:
- If latency > 250ms OR cost_per_min > 0.01, recommend switching provider to the other simulated provider.
- Attach a confidence score and reason.
"""
from __future__ import annotations
import time
import random
import argparse
import threading
import requests
from datetime import datetime
from typing import Dict

BACKEND_HTTP = "http://127.0.0.1:8000"
PROVIDERS = ["aws", "alibaba"]


def generate_telemetry(service_name: str) -> Dict:
    """Generate a simulated telemetry sample."""
    provider = random.choice(PROVIDERS)
    region = random.choice(["us-east-1", "eu-west-1", "cn-hangzhou"])
    cpu = round(random.uniform(0.1, 0.95), 2)
    memory = round(random.uniform(0.05, 0.9), 2)
    latency_ms = int(random.gauss(120 if provider == 'aws' else 180, 60))
    latency_ms = max(20, latency_ms)
    # cost per minute simulated (USD)
    base_cost = 0.002 if provider == 'aws' else 0.0018
    cost_per_min = round(base_cost * (1 + cpu), 6)
    ts = datetime.utcnow().isoformat() + 'Z'
    return {
        "service": service_name,
        "provider": provider,
        "region": region,
        "cpu": cpu,
        "memory": memory,
        "latency_ms": latency_ms,
        "cost_per_min": cost_per_min,
        "timestamp": ts
    }


def simple_decision_rule(sample: Dict) -> Dict:
    """Simple rule-based decision maker.

    - If latency > 250ms or cost_per_min > 0.01 recommend switching provider.
    - Otherwise, no-op (recommend current provider).
    Returns a decision dict.
    """
    latency = sample.get('latency_ms', 0)
    cost = sample.get('cost_per_min', 0)
    current = sample.get('provider')
    other = [p for p in PROVIDERS if p != current][0]
    confidence = 0.5
    reason = 'stable'
    recommend = current
    if latency > 250 or cost > 0.01:
        recommend = other
        confidence = 0.85 if latency > 400 or cost > 0.03 else 0.7
        reason = f"high_latency ({latency})" if latency > 250 else f"high_cost ({cost})"
    else:
        confidence = 0.92
        reason = "within_expected"

    return {
        "service": sample['service'],
        "current_provider": current,
        "recommended_provider": recommend,
        "region": sample['region'],
        "reason": reason,
        "confidence": confidence,
        "timestamp": datetime.utcnow().isoformat() + 'Z'
    }


class Simulator:
    def __init__(self, service_name: str = 'fetcher', mode: str = 'http', interval: float = 5.0):
        self.service = service_name
        self.mode = mode
        self.interval = interval
        self._stop = threading.Event()

    def send_telemetry_http(self, payload: Dict):
        try:
            requests.post(f"{BACKEND_HTTP}/telemetry", json=payload, timeout=2)
        except Exception as e:
            print('HTTP telemetry send failed:', e)

    def send_decision_http(self, decision: Dict):
        try:
            requests.post(f"{BACKEND_HTTP}/decisions", json=decision, timeout=2)
        except Exception as e:
            print('HTTP decision send failed:', e)

    def send_telemetry_inproc(self, payload: Dict):
        # import inside method to keep module lightweight when not used
        from api import main as backend
        # call backend route function directly
        # backend.post_telemetry is async def; call via asyncio
        import asyncio
        asyncio.run(backend.post_telemetry(payload))

    def send_decision_inproc(self, decision: Dict):
        from api import main as backend
        import asyncio
        asyncio.run(backend.post_decision(decision))

    def step_once(self):
        sample = generate_telemetry(self.service)
        decision = simple_decision_rule(sample)
        if self.mode == 'http':
            self.send_telemetry_http(sample)
            self.send_decision_http(decision)
        else:
            self.send_telemetry_inproc(sample)
            self.send_decision_inproc(decision)
        return sample, decision

    def run(self):
        print(f"Starting simulator for service={self.service} mode={self.mode} interval={self.interval}s")
        while not self._stop.is_set():
            sample, decision = self.step_once()
            print("emitted telemetry:", sample)
            print("decision:", decision)
            time.sleep(self.interval)

    def stop(self):
        self._stop.set()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', choices=['http', 'inproc'], default='http')
    parser.add_argument('--service', default='fetcher')
    parser.add_argument('--interval', type=float, default=5.0)
    args = parser.parse_args()
    sim = Simulator(service_name=args.service, mode=args.mode, interval=args.interval)
    try:
        sim.run()
    except KeyboardInterrupt:
        print('stopping simulator')


if __name__ == '__main__':
    main()
