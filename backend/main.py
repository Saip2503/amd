from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Optional, Any
import os
from dotenv import load_dotenv
from google import genai
from google.genai import types
import json

load_dotenv()

app = FastAPI(title="Nutriflow API")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    client = genai.Client(api_key=GEMINI_API_KEY)
else:
    client = None

# Mock Database for User State & Preferences
MOCK_USER_DB = {
    "preferences": {
        "diet": "Standard",
        "notifications": True
    },
    "state": {
        "calories": {"actual": 1450, "target": 2100},
        "macros": {
            "protein": {"actual": 85, "target": 120},
            "carbs": {"actual": 150, "target": 220},
            "fats": {"actual": 45, "target": 65}
        },
        "recent_activity": [
            {"title": "Quinoa Power Bowl", "time": "Lunch • 1:20 PM", "calories": "450 kcal"},
            {"title": "Green Detox Smoothie", "time": "Snack • 10:45 AM", "calories": "180 kcal"}
        ]
    }
}

# --- Pydantic Models ---

class UserContext(BaseModel):
    time: str
    recent_workout: bool

class ChatRequest(BaseModel):
    message: str
    context: UserContext

class RecipeCard(BaseModel):
    name: str
    prep_time: str
    calories: int
    protein: int
    carbs: int
    fats: int
    ingredients: List[str]

class ChatResponse(BaseModel):
    text: str
    recipe: Optional[RecipeCard] = None

class PreferencesUpdateRequest(BaseModel):
    diet: Optional[str] = None
    notifications: Optional[bool] = None

# --- API Endpoints ---

@app.get("/")
def read_root():
    return {"message": "Welcome to the Nutriflow API"}

@app.get("/api/user/state")
def get_user_state():
    return {"data": MOCK_USER_DB["state"]}

@app.patch("/api/user/preferences")
def update_user_preferences(prefs: PreferencesUpdateRequest):
    if prefs.diet is not None:
        MOCK_USER_DB["preferences"]["diet"] = prefs.diet
    if prefs.notifications is not None:
        MOCK_USER_DB["preferences"]["notifications"] = prefs.notifications
    return {"data": MOCK_USER_DB["preferences"]}

@app.post("/api/chat", response_model=ChatResponse)
def chat_with_assistant(request: ChatRequest):
    if not client:
        raise HTTPException(status_code=500, detail="Gemini API Key is not configured in .env")

    user_diet = MOCK_USER_DB["preferences"]["diet"]
    
    system_instruction = (
        "You are Nutriflow's Assistant. You provide highly curated, structured food advice. "
        f"The user's current diet preference is {user_diet}. "
        "Return your response ONLY as a JSON object matching this schema:\n"
        '{"text": "Your conversational response", "recipe": null or {"name": "...", "prep_time": "...", "calories": 123, "protein": 12, "carbs": 34, "fats": 5, "ingredients": ["..."]}}'
    )

    prompt = (
        f"User Message: '{request.message}'\n"
        f"Context: Time is {request.context.time}, Recent Workout: {request.context.recent_workout}\n"
    )

    try:
        response = client.models.generate_content(
            model="gemini-1.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.7,
                response_mime_type="application/json",
            ),
        )
        
        # Parse the JSON response
        data = json.loads(response.text)
        return ChatResponse(**data)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini Inference Error: {str(e)}")

@app.post("/api/planner/generate")
def generate_meal_plan():
    if not client:
        raise HTTPException(status_code=500, detail="Gemini API Key is not configured in .env")

    user_diet = MOCK_USER_DB["preferences"]["diet"]
    
    system_instruction = (
        "You are Nutriflow's meal planner. Generate a 7-day meal plan (Mon-Sun). "
        f"Adhere to the {user_diet} diet. "
        "Return ONLY a JSON array of objects with schema: [{'day': 'Monday', 'breakfast': '...', 'lunch': '...', 'dinner': '...'}, ...]"
    )

    try:
        response = client.models.generate_content(
            model="gemini-1.5-flash",
            contents="Generate next week's meal plan.",
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.7,
                response_mime_type="application/json",
            ),
        )
        data = json.loads(response.text)
        return {"data": {"plan": data}}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini Inference Error: {str(e)}")
