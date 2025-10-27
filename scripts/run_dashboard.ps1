# Run the Streamlit dashboard using the project's venv Python
$venv = "C:\Users\user\Documents\AIOPS\.venv\Scripts\python.exe"
Start-Process -FilePath $venv -ArgumentList "-m streamlit run dashboard/streamlit_app.py --server.port 8501 --server.headless true" -NoNewWindow -PassThru
Write-Output "Started dashboard using $venv"