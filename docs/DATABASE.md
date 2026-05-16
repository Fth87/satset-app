# Supabase Database Schema

This application relies on a Supabase PostgreSQL backend. Below are the core tables, relationships, and Row Level Security (RLS) policies implemented to secure the data.

## Tables

### 1. `profiles`
Stores extended user profile information linked to the authentication system.
- `id` (UUID, Primary Key): References `auth.users(id)` on delete cascade.
- `name` (TEXT): The operator's full name.
- `role` (TEXT): Must be either `'courier'` or `'dispatcher'`. Dictates UI routing upon login.
- `zone` (TEXT, Nullable): The operational zone.
- `vehicle` (TEXT, Nullable): Vehicle details if applicable.

**RLS Policies:**
- `Authenticated users can read profiles`: Allows any logged-in user to view profile data (e.g., dispatcher viewing courier profiles).
- `Authenticated users can update profiles`: Allows profile modification by logged in users.

### 2. `packages`
Manages all delivery package states and metadata.
- `id` (TEXT, Primary Key): Unique tracking ID (e.g., 'PKG-001').
- `recipient` (TEXT): Name of the receiver.
- `address` (TEXT): Delivery address.
- `status` (TEXT): Current state (`pending`, `clarification`, `delivered`).
- `priority` (TEXT): Delivery priority.
- `eta` (TEXT): Estimated time of arrival.
- `confidence` (INT): AI confidence score for address or routing (0-100).
- `cluster` (TEXT): Routing cluster group.
- `courier_id` (UUID, Foreign Key): References `profiles(id)`. Determines which courier is assigned.

**RLS Policies:**
- `Authenticated users can read packages`: Anyone logged in can see package data.
- `Authenticated users can update packages`: Allows couriers and dispatchers to change statuses.
- `Authenticated users can insert packages`: Allows dispatchers/system to create new packages.

### 3. `chat_messages`
Stores AI clarification dialogues and incident report logs per package.
- `id` (UUID, Primary Key): Auto-generated unique ID.
- `package_id` (TEXT, Foreign Key): References `packages(id)` on delete cascade.
- `sender` (TEXT): Sender type (`ai`, `customer`, `courier`).
- `text` (TEXT): Message body.
- `time` (TEXT): Timestamp string (e.g. '08:15').

**RLS Policies:**
- `Authenticated users can read chat_messages`: Read access for operators.
- `Authenticated users can insert chat_messages`: Allows adding new logs.

---

## Authentication Flow
The application uses **Supabase Auth** (Email/Password provider).
When a user logs in via the app, the `AppController` queries the `profiles` table using the user's UUID to determine their `role`. 
- If `role == 'dispatcher'`, the app routes to the Dispatcher Dashboard.
- If `role == 'courier'`, the app routes to the Courier Dashboard.
