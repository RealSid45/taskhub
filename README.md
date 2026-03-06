# Mini TaskHub — Flutter Internship Assignment

A personal task tracking app built with Flutter and Supabase.

Demo Video: [Click here](https://drive.google.com/file/d/1b0Zrsj0aEX03YCu3kn_lc2P0LSRMIyC2/view?usp=drive_link)  
GitHub: [github.com/RealSid45/taskhub](https://github.com/RealSid45/taskhub)

---

## Features

- Email/password login and sign up via Supabase
- Add, delete, edit, and complete tasks
- Filter tasks — All / Pending / Done
- Light and dark theme toggle
- Smooth animations throughout
- Optimistic UI updates

---

## Setup Instructions

### 1. Clone the repo
```
git clone https://github.com/RealSid45/taskhub.git
cd taskhub
```

### 2. Install dependencies
```
flutter pub get
```

### 3. Create a `.env` file at the project root

The Supabase project is already set up with the tasks table and RLS policies.
Use the credentials below — no additional Supabase setup is needed.

```
SUPABASE_URL=https://kufmdsrtqjnohnmchenv.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1Zm1kc3J0cWpub2hubWNoZW52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2Mzk1NjMsImV4cCI6MjA4ODIxNTU2M30.-KLv9CdZiwVGsyXbdsldpOSKB0Z7ZTYAw86oGduA-pM
```

### 4. Run the app
```
flutter run
```

---

## Supabase Details

The Supabase project is already configured with the following:

- Email authentication enabled
- Tasks table created with the schema below
- Row Level Security enabled — each user can only access their own tasks

Tasks table schema:

```sql
create table public.tasks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  title       text not null,
  completed   boolean not null default false,
  created_at  timestamptz not null default now()
);
```

---

## Hot Reload vs Hot Restart

Hot Reload injects updated code into the running app without losing state.
It is fast and useful for UI changes.

Hot Restart fully restarts the Dart VM and resets all app state from scratch.
It is slower and needed when changing initState, providers, or app initialization.

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   └── theme.dart
├── Auth/
│   ├── LoginView.dart
│   ├── SignupView.dart
│   └── AuthService.dart
├── Dashboard/
│   ├── Dashboard.dart
│   ├── task_tile.dart
│   └── task_model.dart
├── Services/
│   └── supabaseServices.dart
└── Providers/
    └── themeProvider.dart
```

---

## Tech Stack

- Flutter — UI framework
- Supabase — authentication and database
- Provider — state management
- Google Fonts — typography
- flutter_dotenv — environment variables