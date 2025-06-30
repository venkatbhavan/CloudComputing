from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from azure.storage.blob import BlobServiceClient
import pandas as pd
import io
import os
from dotenv import load_dotenv

app = FastAPI()
templates = Jinja2Templates(directory="templates")

load_dotenv()

# Azure Blob Storage Configuration
AZURE_CONNECTION_STRING = os.getenv('AZURE_CONNECTION_STRING')
CONTAINER_NAME = os.getenv('CONTAINER_NAME')
BLOB_NAME = os.getenv('BLOB_NAME')

def fetch_csv_from_blob():
    blob_service_client = BlobServiceClient.from_connection_string(AZURE_CONNECTION_STRING)
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=BLOB_NAME)
    blob_data = blob_client.download_blob()
    return pd.read_csv(io.BytesIO(blob_data.readall()))

@app.get("/", response_class=HTMLResponse)
async def form_get(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/result", response_class=HTMLResponse)
async def fetch_student_data(request: Request, student_id: int = Form(...), dob: str = Form(...)):
    df = fetch_csv_from_blob()
    df["DOB"] = pd.to_datetime(df["DOB"]).dt.date
    dob_parsed = pd.to_datetime(dob).date()

    student_row = df[(df["StudentID"] == student_id) & (df["DOB"] == dob_parsed)]

    if not student_row.empty:
        data = student_row.iloc[0].to_dict()
        return templates.TemplateResponse("result.html", {"request": request, "data": data})
    else:
        return templates.TemplateResponse("result.html", {"request": request, "data": None, "error": "Student not found."})

if __name__ == "__main__":
    import uvicorn
    print("App is running at http://127.0.0.1:8000 🚀")
    uvicorn.run(app, host="127.0.0.1", port=8000, reload=False)

