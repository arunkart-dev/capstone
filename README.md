📘 Capstone - Math Learning App

Capstone is a gamified math learning app built with Flutter. It helps students learn mathematics through:
✅ Daily quizzes & assignments
✅ Progress tracking & streaks
✅ Badges & achievements
✅ Motivational daily quotes (via Gemini API)
✅ Stress-free bot for assistance
✅ Light & Dark theme toggle

✨ Features

📚 Lessons: Structured math learning topics.

📝 Assignments: Auto-generated daily practice problems.

❓ Quizzes: Fresh quizzes generated every day.

🏆 Badges: Unlock rewards (e.g., Quiz Master, Streak King).

📈 Progress: Track completed topics and streak consistency.

🤖 Chat Bot: Stress-free AI-powered helper for queries.

🌗 Dark/Light Theme: Toggle themes with persistence via SharedPreferences.

💡 Daily Quotes: Motivational quotes fetched from Gemini API.

🛠️ Tech Stack

Framework: Flutter (Dart)

Database: SQLite (via sqflite)

State Management: Provider

Storage: SharedPreferences (for theme persistence)

API: Google Generative AI (Gemini)

📂 Project Structure
lib/
 ├── databases/
 │   └── db_helper.dart         # Database helper for quizzes, assignments, chats
 ├── providers/
 │   └── theme_provider.dart    # Theme management with Provider + SharedPreferences
 ├── screens/
 │   ├── splashscreen.dart      # Splash screen
 │   ├── homescreen.dart        # Dashboard
 │   ├── lessonscreen.dart      # Lesson viewer
 │   ├── quiz_screen.dart       # Quiz module
 │   ├── gamifyscreen.dart      # Gamification module
 │   ├── assignmentsscreen.dart # Assignments
 │   ├── progressscreen.dart    # Track user progress
 │   ├── badgesscreen.dart      # Badge collection
 │   └── chat_screen.dart       # Stress-free bot
 ├── services/
 │   └── gemini_service.dart    # Handles AI requests
 └── main.dart                  # Entry point

🚀 Getting Started
1️⃣ Prerequisites

Install Flutter

Google Gemini API key (for daily quotes, chat, quizzes)

2️⃣ Clone the Repo
git clone https://github.com/your-username/capstone-math-app.git
cd capstone-math-app

3️⃣ Install Dependencies
flutter pub get

4️⃣ Configure API Key

Inside gemini_service.dart, replace _apiKey with your key:

static const String _apiKey = "YOUR_API_KEY_HERE";

5️⃣ Run the App
flutter run

⚠️ Notes

If Gemini API is overloaded (503 error), the app will still run but may not fetch quotes or AI responses.

You can switch models (gemini-1.5-pro or gemini-1.5-flash) depending on availability.

📸 Screenshots

(Add your app screenshots here — Home, Quiz, Badges, Dark Mode, etc.)

👨‍💻 Contributors

You (Lead Developer) ✨

Open for contributions!

📜 License

This project is licensed under the MIT License.
