
from fastapi import FastAPI, UploadFile, File, HTTPException
from ultralytics import YOLO
import io
from PIL import Image
import numpy as np
from typing import List, Dict, Any

# Initialize FastAPI app
app = FastAPI(title="YOLO Classification API", version="1.0.0", description="API to classify images using a YOLO model.")

# Load YOLO model
MODEL_PATH = "/app/yolo11n.pt"  # Corrected path inside the Docker container

# MODEL_PATH = "yolo11n.pt"  # Path to YOLO model
try:
    model = YOLO(MODEL_PATH)
except Exception as e:
    raise RuntimeError(f"Failed to load YOLO model from {MODEL_PATH}: {e}")


@app.post("/classify/", response_model=Dict[str, Any])
async def classify(file: UploadFile = File(...)):
    """
    Endpoint to classify an image using a YOLO model.
    
    Args:
        file (UploadFile): Uploaded image file in JPEG or PNG format.
    
    Returns:
        dict: A dictionary containing predictions with class IDs, confidence scores, and bounding boxes.
    """
    # Validate file type
    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload a JPEG or PNG image.")

    try:
        # Read image data and convert to a numpy array
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        img_array = np.array(image)

        # Run inference
        results = model.predict(img_array)

        # Extract predictions
        predictions = []
        for box in results[0].boxes.data.tolist():  # Iterate through detected bounding boxes
            x1, y1, x2, y2, confidence, class_id = box
            predictions.append({
                "class_id": int(class_id),
                "confidence": float(confidence),
                "bbox": [x1, y1, x2, y2],
            })

        return {"predictions": predictions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error during classification: {e}")
