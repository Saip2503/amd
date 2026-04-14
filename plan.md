# Nutriflow: The Living Canvas of Wellness

## 📌 Project Vision
Nutriflow is a high-end nutrition and wellness platform that transforms caloric tracking into an editorial, "living" experience. By bridging health data with real-world location intelligence and AI-driven insights, it provides users with "Active Clarity" for their nutritional decisions.

---

## 🏗️ 1. The Frontend (Mobile App)
**Framework:** Flutter (Dart)  
**State Management:** Riverpod (Reactive UI)

*   **Why:** Ensures the interface feels fresh and responsive. Caloric gaps and recommendations update instantly as data flows in.
*   **Networking:** Dio (API Management)
*   **Local Storage:** Hive (Lightweight, NoSQL) - stores dietary preferences (Vegan, Keto) and local session state.

---

## ⚙️ 2. The Logic Layer (Backend)
**Framework:** FastAPI (Python)  
**Deployment:** Google Cloud Run (Serverless)

*   **Modular Intelligence:** Acts as the high-speed bridge between the mobile client and the Google ecosystem.
*   **Scalability:** Scales to zero when not in use, ensuring efficiency while maintaining performance during peak health-tracking hours.

---

## 🧠 3. The AI & Agent Layer
**Orchestration:** Google Antigravity  
**Engine:** Gemini 1.5 Pro (via Google-GenAI SDK)

*   **Conversational Logic:** Manages complex conversational states and tool-calling for personalized nutrition advice.
*   **Contextual Reasoning:** Parses natural language prompts ("I'm hungry") alongside physiological data to generate safe, personalized recommendations.

---

## 🌍 4. The Context & Data Services
**Health Integration:** Google Health Connect (Android) / Apple HealthKit (iOS)  
**Location Services:** Google Maps Platform (Places API)

*   **Real-time Vitals:** Pulls steps, active minutes, and calories burned straight from the device.
*   **Geospatial Intelligence:** Fetches nearby healthy restaurants based on the user's exact GPS coordinates and dietary goals.

---

## 🚀 The workflow: Stitched Together
1.  **Ingestion:** User opens the app; steps and vitals are synced locally.
2.  **Request:** User asks, "What should I eat?"
3.  **Contextual POST:** Flutter sends current steps, GPS, and dietary profile to `/ask` on FastAPI.
4.  **Discovery:** FastAPI queries Google Places for nearby "Healthy" tagged restaurants.
5.  **Synthesis:** Gemini synthesizes the vitals, location, and user preferences into a curated recommendation.
6.  **Presentation:** The "Living Canvas" UI renders the result with sophisticated asymmetry and editorial clarity.
