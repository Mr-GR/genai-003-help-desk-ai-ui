# Help Desk AI - Flutter UI

A sleek mobile UI for the Help Desk AI Agent, built using Flutter and following a micro-architecture design.

---

## Features

- 🔐 Login / Sign-up screen with auto-login via stored JWT
- 💬 Chat interface with RAG or LLM support
- 🧭 Home page with navigation buttons (Chat, Docs, Logout)
- 🎨 Consistent color theme and responsive layout
- ✅ Token-based request protection

---

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Ensure iOS/Android Setup
```bash
flutter doctor
```

> If needed, run:
> ```bash
> cd ios && pod install
> ```

---

## Micro-Architecture Overview

```
lib/
├── main.dart                # Entry point
├── pages/
│   ├── login_sign_up.dart   # Login/Signup toggle UI
│   ├── home.dart            # Chat/Docs/Logout buttons
│   └── chat.dart            # Main AI interaction
└── services/
    └── api_service.dart     # HTTP API & token handling
```

---

## Token Handling

- Token is stored in `SharedPreferences`
- Auto-login if token exists
- All secure endpoints include header:
```dart
"Authorization": "Bearer <your_token>"
```
- Sign out clears the stored token

---

## Testing Endpoints (Optional)

Use [Postman](https://www.postman.com/) or curl to test:

```bash
curl -X POST http://localhost:8080/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=demo&password=demo123"
```

```bash
curl -X POST http://localhost:8080/request \
  -H "Authorization: Bearer <your_token>" \
  -H "Content-Type: application/json" \
  -d '{"ticket": "How to update macOS?"}'
```

---

## Routing

```dart
initialRoute: '/',
routes: {
  '/': (context) => const LoginSignUpPage(),
  '/home': (context) => const HomePage(),
  '/chat': (context) => const ChatPage(),
}
```

---

## Stretch Goals

- Add role-based auth (admin/users)
- Integrate file uploads (e.g., PDF receipts)
- Sync ticket history from PostgreSQL

---

