from fastapi import FastAPI
from .inference_onnx import ColaONNXPredictor

app = FastAPI(title="MLOps Basics App")

predictor = ColaONNXPredictor("./models/model.onnx")


@app.get("/")
async def home_page():
    return "<h2>Sample prediction API</h2>"


@app.get("/predict")
async def get_prediction(text: str):
    result = predictor.predict(text)

    # Converting the result to a more readable format via API
    result = [
        {"label": res["label"], "score": round(float(res["score"]), 3)}
        for res in result
    ]

    return result


# python3 -m uvicorn src.app:app
# docker run -it -p 8000:8000 inference:test
