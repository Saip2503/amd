# Nutriflow: System Architecture & Design

## 📌 Overview
The architectural backbone of the Nutriflow ecosystem bridges raw health data with AI intelligence through modular protocols. The system leverages a **Language-based Intelligence Layer** (LSP-inspired) while integrating the **Model Context Protocol (MCP)** to allow AI agents to navigate the physical world (Google Maps, Health Connect).

---

## 🧠 Intelligence Architecture: Client-Server Model
The architecture strictly decouples the user interface from the analytical intelligence, ensuring modularity and performance.

### 1. Client (Nutriflow UI)
Built with **Flutter**, it acts as a "reactive presentation layer." 
*   **Syntax:** Renders nutritional data, maps, and health metrics.
*   **State:** Uses Riverpod to maintain a real-time reactive loop with the backend.

### 2. Server (The Nutrition Analyzer)
A standalone **FastAPI** process that ingests health data, parses user intent, and performs background analysis.
*   **The Repository of Truth:** Holds the current state of user goals, dietary restrictions, and caloric intake.

---

## 🔌 Communication Layer (JSON-RPC 2.0)
The Client and Server communicate continuously to maintain a "Living Canvas" experience.

*   **Lifecycle Flow:**
    1.  **Initialize:** Flutter client establishes context with the backend.
    2.  **Notification:** User activity (steps/calories) is pushed asynchronously to the analyzer.
    3.  **Action:** AI "diagnoses" nutritional gaps and suggests immediate code/meal actions.

---

## ⚡ Concurrency & State Management
To ensure a fluid experience (no UI freezing during AI inference):

*   **Incremental Sync:** Only text deltas and specific health data changes are sent to the backend.
*   **Virtual Context:** The server maintains an in-memory "Digital Twin" of the user's current physical state.
*   **Asynchronous AI:** Long-running Gemini inference is pushed to worker threads, with status updates streamed back to Flutter.

---

## 🎨 Design Philosophy: The Living Canvas
Following the "Nutriflow UI" core principles:

*   **Sophisticated Asymmetry:** Documentation and UI avoid rigid grids in favor of rhythmic flow.
*   **No-Line Rule:** Boundaries are defined strictly by background color transitions (#eff1ef to #f5f7f5).
*   **Layering:** Elements stack like thin sheets of paper using tonal depth instead of harsh shadows.
