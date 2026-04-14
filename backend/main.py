from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

app = FastAPI(title="Nutriflow API")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    client = genai.Client(api_key=GEMINI_API_KEY)
else:
    client = None

class RecommendationRequest(BaseModel):
    step_count: int
    latitude: float
    longitude: float
    user_prompt: str

@app.get("/")
def read_root():
    return {"message": "Welcome to the Nutriflow API"}

def mock_places_api(lat: float, lng: float):
    # Mocking Google Places API for nearby healthy restaurants
    return [
        {"name": "Green Bowl Co.", "type": "Salad & Grain Bowls", "distance_meters": 450},
        {"name": "Protein Point", "type": "Health Food Grill", "distance_meters": 800},
        {"name": "Vitality Juice Bar", "type": "Smoothies & Wraps", "distance_meters": 300}
    ]

@app.post("/ask")
def get_recommendation(request: RecommendationRequest):
    if not client:
        raise HTTPException(status_code=500, detail="Gemini API Key is not configured in .env")

    # 1. Fetch nearby healthy places based on GPS (Mocked)
    nearby_places = mock_places_api(request.latitude, request.longitude)
    places_context = "\n".join([f"- {p['name']} ({p['type']}, {p['distance_meters']}m away)" for p in nearby_places])

    # 2. Build the Intelligence Context
    system_instruction = (
        "You are Nutriflow, an elite, high-end nutrition AI. Your goal is to provide a highly curated, "
        "personalized food recommendation. Use an editorial, energetic, and sophisticated tone. Keep it concise."
    )

    prompt = (
        f"User Prompt: '{request.user_prompt}'\n"
        f"Current Steps Today: {request.step_count} (Assess their caloric need based on this activity)\n"
        f"Nearby Healthy Options:\n{places_context}\n\n"
        "Based on this exact data, recommend a specific meal from one of the nearby options. "
        "Explain *why* this matches their current activity level."
    )

    # 3. Query Gemini for synthesis
    try:
        response = client.models.generate_content(
            model="gemini-1.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.7,
            ),
        )
        recommendation_text = response.text
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini Inference Error: {str(e)}")

    # 4. Return to Flutter UI
    return {
        "status": "success",
        "data": {
            "received_prompt": request.user_prompt,
            "steps": request.step_count,
            "location": {"lat": request.latitude, "lng": request.longitude},
            "recommendation": recommendation_text
        }
    }
