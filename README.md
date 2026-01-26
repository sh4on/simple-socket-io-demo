# Flutter Socket.IO Chat Demo

A clean, lightweight demonstration of real-time bi-directional communication in Flutter using **Socket.IO** and **GetX**.

## 📌 Project Overview
This project serves as a focused technical demo showcasing how to implement a robust messaging interface with reactive state management. While the UI is kept simple and intuitive, the underlying architecture is designed to handle the complexities of real-time data synchronization, connection states, and asynchronous event handling.

## 🎯 Purpose
I developed this demo to showcase:
- **Scalable Architecture:** Clean separation of business logic and UI.
- **Efficient Reactivity:** Using GetX to manage UI states without unnecessary rebuilds.
- **Reliable Communication:** Handling Socket.IO events (connect, disconnect, errors, and custom events) gracefully.

## 🚀 Key Technical Features
- **Real-Time Messaging:** Bi-directional data flow with low latency.
- **Dynamic Context Awareness:** Automatically identifies user roles (Owner/Customer) to display appropriate metadata (names/avatars).
- **Reactive UX:** Instant UI feedback for connection status and message delivery.
- **Optimized Chat History:** Implemented reverse-loading logic for a familiar "bottom-first" chat experience.

## 🛠 Tech Stack & Patterns
- **Flutter SDK:** Cross-platform UI framework.
- **GetX:** State management and dependency injection.
- **Socket.io Client:** WebSocket-based real-time communication.
- **Clean Code Principles:** Modularized controllers and screens for maintainability.

## 🏗 Project Structure
```text
lib/
├── chat/
│   ├── controller/     # Business logic & Socket events
│   └── screens/        # UI components & reactive views
└── main.dart           # App entry & initialization
```

## ⚙️ Setup & Installation
1. **Clone the project:**
   ```bash
   git clone https://github.com/your-username/socket_io_demo.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Environment:**
   Update the `socketUrl` and `authToken` in `lib/chat/controller/chat_controller.dart`.
4. **Run:**
   ```bash
   flutter run
   ```

---
*This is a portfolio project designed to demonstrate engineering quality over UI complexity. I'm always open to discussing the architectural choices made here!*
