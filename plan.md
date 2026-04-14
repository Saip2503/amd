# 🚀 Nutri-Flow: Full-Stack Implementation Plan

This document outlines the step-by-step implementation strategy to build the Nutri-Flow application, translating the provided UI designs into a functional Flutter frontend and a lightweight FastAPI backend utilizing the Agent-Driven Nutrition Server Protocol (NSP).

---

## 🏗️ Phase 1: Environment & Architecture Setup

**Goal:** Establish the monorepo structure while strictly adhering to the `< 1 MB` hackathon repository limit.

1.  **Repository Structure:**
    ```text
    nutri-flow/
    ├── frontend/          # Flutter application
    ├── backend/           # FastAPI application
    ├── .gitignore
    ├── README.md
    └── DESIGN.md          # Architecture documentation
    ```
2.  **Backend Initialization (Python/FastAPI):**
    * Set up a virtual environment.
    * Define `requirements.txt`: `fastapi`, `uvicorn`, `google-genai`, `google-api-python-client`, `pydantic`, `python-dotenv`.
    * Create the core `main.py` entry point and router structure.
3.  **Frontend Initialization (Flutter):**
    * Run `flutter create frontend`.
    * Clean up default boilerplate.
    * Add core dependencies to `pubspec.yaml`: `flutter_riverpod` (state), `dio` or `http` (networking), `google_fonts` (typography), `fl_chart` (for dashboard visualizations).

---

## ⚙️ Phase 2: Backend API Development (FastAPI)

Develop the RESTful endpoints and AI tool-calling logic that power the UI screens. Use in-memory dictionaries or lightweight JSON files for state to avoid database bloat.

### 1. Dashboard & Core State (`/api/user/state`)
* **Method:** `GET`
* **Purpose:** Powers the "Daily Flow" screen.
* **Response Model:** Returns current caloric intake (e.g., 1,450 / 2,100 kcal), macro breakdown (Protein, Carbs, Fats targets vs. actuals), and a list of `RecentActivity` (e.g., Quinoa Power Bowl).
* **Integration:** Mock the Health API sync here to calculate remaining calories.

### 2. The Assistant / NSP Engine (`/api/chat`)
* **Method:** `POST`
* **Purpose:** The core AI engine powering the "Assistant" tab.
* **Payload:** `{ "message": "I'm hungry", "context": { "time": "08:15 AM", "recent_workout": true } }`
* **Logic:**
    * Ingest the prompt.
    * Inject system instructions utilizing the `google-genai` SDK.
    * Generate a structured response (using Pydantic schema enforcement via Gemini) that includes conversational text and, if applicable, a structured `RecipeCard` object (like the "Spinach & Feta Boost").

### 3. Meal Planner (`/api/planner/generate`)
* **Method:** `POST`
* **Purpose:** Powers the "Meal Planner" weekly grid.
* **Logic:** Trigger the LLM to generate a 7-day meal plan based on the user's active diet preferences (e.g., Keto, Vegan). Return a structured JSON matrix mapping days (Mon-Sun) to meal types (Breakfast, Lunch, Dinner).

### 4. Settings & Preferences (`/api/user/preferences`)
* **Method:** `PATCH`
* **Purpose:** Updates variables from the "Settings" screen (e.g., toggling "Strictly Vegan").
* **Impact:** This updates the user's core configuration, which is dynamically injected into the Gemini system prompt for all future `/api/chat` and `/api/planner` requests.

---

## 📱 Phase 3: Frontend UI Development (Flutter)

Build the reactive user interface based on the provided mockups. Since the designs show a wide layout, utilize responsive design principles (e.g., `Row` for tablet/web, `Column` or `BottomNavigationBar` for mobile).

### 1. Layout Shell & Navigation
* Create a `MainScaffold` widget.
* Implement a `NavigationRail` or a custom Sidebar widget for the left menu (Dashboard, Meal Planner, Assistant, Library, Settings).
* Implement the floating "I'm Hungry" global action button.

### 2. Dashboard Screen (Image 1)
* **Hero Widget:** Use `fl_chart` to create the circular `PieChart` representing caloric progress.
* **Macro Cards:** Build custom `LinearProgressIndicator` widgets for Protein, Carbs, and Fats.
* **Insight Card:** Create a stylized container for the "Focus on Fiber" AI recommendation.
* **List View:** Build a `ListView.builder` for the "Recent Activity" items.

### 3. Assistant Screen (Image 2)
* **Chat Interface:** Implement a `ListView` that differentiates between `UserMessageBubble` and `AiMessageBubble`.
* **Rich AI Responses:** Create a custom `RecipeCardWidget` that the chat interface renders when the backend returns structured recipe data (showing prep time, macros, and ingredients).
* **Input Field:** Build a text field with a microphone icon (for future speech-to-text) and a submit button.

### 4. Meal Planner Screen (Image 3)
* **Grid Layout:** Use a horizontal `ListView` or `SingleChildScrollView` containing columns for each day of the week.
* **Meal Tiles:** Build compact cards for individual meals (e.g., "Power Oats", "Avocado Crisp") showing calories and a small thumbnail.
* **Summary Footer:** Create a sticky bottom component showing weekly macro forecasts and the generated shopping list count.

### 5. Library Screen (Image 4)
* **Layout:** A scrolling view with section headers ("Knowledge for your Wellbeing", "High Protein Favorites", "Quick Meals").
* **Cards:** Build a horizontal `ListView` for recipe/article cards. This is an excellent place to mock a lightweight Retrieval-Augmented Generation (RAG) query if the user searches for specific health topics.

### 6. Settings Screen (Image 5)
* **Forms:** Implement text fields for user details.
* **Toggles:** Use `SwitchListTile` widgets for Diet Preferences (Keto, Vegan) and Notifications.
* **Integrations:** Create visual rows for Apple Health and Fitbit with Connect/Disconnect action buttons. Use Riverpod to manage these toggle states and push changes to the backend.

---

## 🔌 Phase 4: Integration & State Management

1.  **API Service:** Create an `api_service.dart` file in Flutter to handle all HTTP communication with the FastAPI backend using Dio.
2.  **State Management (Riverpod):**
    * Create a `UserProvider` to hold the current caloric state and preferences.
    * Create a `ChatProvider` to manage the list of messages in the Assistant tab.
3.  **The "I'm Hungry" Flow:**
    * Wire the global green button to instantly slide open the Assistant tab and automatically trigger a context-aware prompt to the `/api/chat` endpoint based on the current time of day.

---

## 🚀 Phase 5: Deployment Strategy

1.  **Backend (Google Cloud Run):**
    * Write a basic `Dockerfile` for the FastAPI app.
    * Deploy the containerized backend to Cloud Run to ensure it is publicly accessible for the hackathon judges.
2.  **Frontend (Web/Mobile):**
    * Compile the Flutter app for Web (`flutter build web`) to provide an easily accessible link for the judges, or run it locally in the Chrome MCP environment for testing the agentic behaviors.
