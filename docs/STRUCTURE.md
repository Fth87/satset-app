# Project Architecture & Structure

This document outlines how the codebase is organized following best practices for separation of concerns, maintaining a modular and scalable Flutter architecture.

## Folder Structure

```text
lib/
├── core/                   # Core business logic and app-wide configurations
│   ├── app_controller.dart # Main State Management (ChangeNotifier) and Routing logic
│   ├── app_theme.dart      # Application design tokens, colors, and global styles
│   ├── constants.dart      # Configuration keys and constants (e.g., Supabase URLs)
│   └── supabase_service.dart # Abstraction layer for all Supabase API calls
│
├── models/                 # Data models and Enums
│   └── package.dart        # Defines `DeliveryPackage`, `OperatorProfile`, `ChatMessage`, etc.
│
├── screens/                # UI Screens separated by domain
│   ├── app_shell.dart      # The main application shell managing the Bottom Navigation bar
│   ├── auth/               # Authentication related screens
│   │   ├── splash_screen.dart       # Initialization loader and auth-check
│   │   ├── login_screen.dart        # Carousel & email/password login form
│   │   └── forgot_password_screen.dart 
│   │
│   ├── courier/            # Screens specific to Courier operations
│   │   ├── dashboard_screen.dart    # Main courier metrics and active packages
│   │   ├── scanner_screen.dart      # Camera implementation for receipt scanning
│   │   ├── map_nav_screen.dart      # Live routing map interface
│   │   └── delivery_detail_screen.dart
│   │
│   ├── dispatcher/         # Screens specific to Dispatcher operations
│   │   ├── dispatcher_dashboard_screen.dart # Fleet oversight
│   │   ├── dispatcher_live_map_screen.dart  # Global cluster map
│   │   └── dispatcher_assignments_screen.dart
│   │
│   └── common/             # Screens shared across multiple roles
│       ├── settings_screen.dart     # App settings and Logout functionality
│       └── profile_screen.dart      # Operator profile details
│
└── widgets/                # Reusable UI Components
    ├── app_widgets.dart    # Base buttons, text fields, and micro-components
    └── app_shell_widgets.dart # Major layout blocks extracted from the old monolithic design
```

## Core State Management (`AppController`)
The app avoids complex 3rd-party state management libraries (like Riverpod or Bloc) to prevent overengineering, relying instead on Flutter's native `ChangeNotifier` via `AppController`.

**Key Responsibilities of `AppController`**:
- **Authentication Initialization**: Listens to Supabase auth events on boot and maintains the active session.
- **Dynamic Routing**: The `go(AppScreen next)` function manages screen transitions without standard Navigator pushes (since the layout relies on a persistent Bottom Nav in `AppShell`).
- **Data Hydration**: Fetches the `profile` and active `packages` globally and notifies all dependent screens.

## The Refactoring Journey
Previously, this app had a massive 3000+ line monolithic file (`app_shell.dart`). It has been successfully parsed and refactored into domain-specific files (`lib/screens/courier`, `lib/screens/auth`, etc.), reducing tight-coupling and dramatically improving readability and maintainability.
