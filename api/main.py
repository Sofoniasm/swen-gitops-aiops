from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import asyncio
import uvicorn

app = FastAPI(title="SWEN AIOps Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory stores (simple for prototype)
telemetry_store = []
decision_history = []

@app.get('/healthz')
async def healthz():
    return {"status": "ok", "current_provider": "simulated"}

@app.post('/telemetry')
async def post_telemetry(payload: dict):
    telemetry_store.append(payload)
    # keep last 500
    if len(telemetry_store) > 500:
        telemetry_store.pop(0)
    return {"result": "stored"}

@app.get('/telemetry')
async def get_telemetry():
    return telemetry_store[-100:]

@app.get('/decisions')
async def get_decisions():
    return decision_history[-200:]


@app.post('/decisions')
async def post_decision(payload: dict):
    """Accept a decision from the AI engine and store it in the decision history.

    Payload should include: service, recommended_provider, region, reason, confidence, timestamp
    """
    # Minimal validation
    required = ["service", "recommended_provider", "region", "reason", "confidence"]
    if not all(k in payload for k in required):
        return {"error": "missing fields", "required": required}
    decision_history.append(payload)
    # keep last 1000
    if len(decision_history) > 1000:
        decision_history.pop(0)
    return {"result": "decision recorded"}


@app.get('/')
async def index():
    """Root helper endpoint with quick links for the prototype."""
    return {
        "message": "SWEN AIOps Backend (simulated)",
        "healthz": "/healthz",
        "telemetry": "/telemetry (GET/POST)",
        "decisions": "/decisions",
        "docs": "/docs"
    }

# Simple WebSocket stream for live telemetry and decisions
@app.websocket('/ws')
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            # send aggregated payload
            payload = {
                'telemetry_tail': telemetry_store[-10:],
                'decisions_tail': decision_history[-10:]
            }
            await websocket.send_json(payload)
            await asyncio.sleep(2)
    except Exception:
        await websocket.close()

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=8000)
