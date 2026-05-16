# Smart Logistics App

A modern, high-performance Flutter application designed for neo-industrial routing and logistics management. This app serves both Couriers (for on-the-ground delivery management, scanning, and routing) and Dispatchers (for high-level fleet tracking and assignment).

## Key Features
- **Role-Based Access**: Automatic routing to Courier or Dispatcher dashboards upon login.
- **Agentic Routing**: High-precision AI-supported routing.
- **Scan & Extract**: Automated receipt reading and location data extraction using the camera.
- **Supabase Backend**: Real-time data synchronization for packages, profiles, and chat messages.

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Supabase Account (if you want to host your own instance)

### Installation
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. The project is pre-configured with a Supabase test instance. If you wish to use your own, update the `Constants.supabaseUrl` and `Constants.supabaseAnonKey` in `lib/core/constants.dart`.
4. Run the app using `flutter run` or build for web using `flutter build web`.

## Test Accounts

The following test accounts have been seeded into the database for testing:

**Courier Account**
- **Email:** `courier@test.com`
- **Password:** `password123`

**Dispatcher Account**
- **Email:** `dispatcher@test.com`
- **Password:** `password123`

## Documentation
- [Database Schema (DATABASE.md)](DATABASE.md)
- [Folder Structure & Architecture (STRUCTURE.md)](STRUCTURE.md)
