# Run the FastAPI backend using the project's venv Python
$venv = "C:\Users\user\Documents\AIOPS\.venv\Scripts\python.exe"
Start-Process -FilePath $venv -ArgumentList "-m uvicorn api.main:app --host 127.0.0.1 --port 8000" -NoNewWindow -PassThru
Write-Output "Started backend using $venv"