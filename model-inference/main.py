from fastapi import FastAPI
from transformers import pipeline
from pydantic import BaseModel
from datetime import datetime
import sqlite3
import os

from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

conn = sqlite3.connect("chat_logs.db", check_same_thread=False)
cursor = conn.cursor()
cursor.execute("""
CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT,
    model_id TEXT,
    prompt TEXT,
    response TEXT
)
""")
conn.commit()

MODEL_ID = os.getenv("MODEL_ID", "distilbert/distilgpt2")
generator = pipeline("text-generation", model=MODEL_ID)

class PromptRequest(BaseModel):
    prompt: str

@app.get("/")
def root():
    return {"message": "Inference API is running"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.post("/generate")
def generate(req: PromptRequest):
    output = generator(req.prompt, max_length=100, do_sample=True, truncation=True)
    response_text = output[0]["generated_text"]

    # Save to DB
    cursor.execute("""
        INSERT INTO logs (timestamp, model_id, prompt, response)
        VALUES (?, ?, ?, ?)
    """, (datetime.utcnow().isoformat(), MODEL_ID, req.prompt, response_text))
    conn.commit()

    return {"response": response_text}

@app.get("/logs")
def get_logs(limit: int = 10):
    cursor.execute(
        "SELECT id, timestamp, model_id, prompt, response FROM logs ORDER BY id DESC LIMIT ?",
        (limit,)
    )
    rows = cursor.fetchall()

    return {
        "logs": [
            {
                "id": row[0],
                "timestamp": row[1],
                "model_id": row[2],
                "prompt": row[3],
                "response": row[4]
            } for row in rows
        ]
    }

