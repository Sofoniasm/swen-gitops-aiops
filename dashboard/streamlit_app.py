import streamlit as st
import requests
import time
import websocket
import threading

BACKEND = st.secrets.get('backend_url', 'http://localhost:8000')

st.set_page_config(page_title='SWEN Cloud Intelligence', layout='wide')

st.title('SWEN Cloud Intelligence — Prototype')

placeholder = st.empty()

# Simple poller fallback
def poll_loop():
    while True:
        try:
            r = requests.get(f"{BACKEND}/telemetry", timeout=2).json()
            decisions = requests.get(f"{BACKEND}/decisions", timeout=2).json()
            with placeholder.container():
                st.subheader('Recent telemetry')
                st.write(r[-5:])
                st.subheader('Recent decisions')
                st.write(decisions[-5:])
        except Exception as e:
            st.write('Backend not available:', e)
        time.sleep(5)

if st.button('Start polling'):
    st.info('Starting polling every 5s — ensure backend is running')
    thread = threading.Thread(target=poll_loop, daemon=True)
    thread.start()

st.markdown('Use the backend `POST /telemetry` endpoint to push simulated telemetry.')
