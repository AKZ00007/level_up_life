# Level Up Life

<p align="center">
  <em>Gamify your habits, track your progress, and turn your daily routine into an epic RPG.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-android-brightgreen.svg?style=for-the-badge&logo=android" alt="Platform Android">
  <img src="https://img.shields.io/badge/status-in%20development-blue.svg?style=for-the-badge" alt="Status In Development">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Made with Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Powered by Firebase">
</p>

---

### 📽 Demo Video

[Click here to watch the demo](https://drive.google.com/file/d/1rk2hZ10f7D2Yte1DW12k0GBXjRnj2egC/preview)



Level Up Life is a mobile application built with Flutter that transforms self-improvement into a captivating role-playing game. Instead of just ticking off tasks, you'll earn experience points (XP), gain levels, and enhance your character's stats by completing real-life activities. This project is currently in active development.
📋 Table of Contents
✨ Features
Gamified Progression System
Activity & Habit Tracking
Immersive User Interface
Advanced Player Profile
Backend & Architecture
📸 Screenshots
🛠️ Tech Stack & Dependencies
🚀 Getting Started
📲 Release
📜 License
✨ Features
Gamified Progression System
Experience & Leveling: Gain XP for every completed activity. Watch your character level up and become more powerful.
Dynamic XP Curve: The XP required to reach the next level increases dynamically, providing a balanced challenge.
Epic Level-Up Notifications: A custom-animated, sci-fi-themed popup announces your new level and title, complete with sound effects.
Character Ranks: Achieve new titles as you advance through levels, from a "Novice Adventurer" to a "Mythic Sovereign".
Streak System: Build and maintain a daily activity streak to earn consistency XP.
Streak Savers: Earn "Streak Savers" at key level milestones (e.g., every 5 levels after level 20) to protect your hard-earned progress.
Activity & Habit Tracking
Timed Activities:
Strength & Intelligence: Engage in focused training sessions using a dedicated, futuristic timer screen. Start, pause, or cancel activities. XP is awarded only upon successful completion.
Sub-Activity Selection: Choose from a list of specific workouts or mental exercises (e.g., "Warrior's Workout", "Mind Quest").
Health Habits:
Water Intake: Log your daily water consumption with a cooldown to encourage consistent hydration throughout the day.
Dental Hygiene: Track teeth brushing with a cooldown to ensure it's logged appropriately.
Daily Activity Calendar: A comprehensive calendar on the profile screen visually marks every day you've logged an activity. This data is fetched directly from a dedicated Firestore log.
Immersive User Interface
Futuristic Dark Theme: A visually rich UI with animated video backgrounds, neon glows, and a cohesive sci-fi aesthetic.
Custom Animations: Smooth and engaging animations using flutter_animate and custom painters for a dynamic user experience.
Sound Effects: An integrated SoundManager provides auditory feedback for clicks, successes, and level-ups, enhancing user immersion.
Custom Widgets: Features a custom-painted circular timer, a sharp-edged progress bar, and many other unique UI components.
Advanced Player Profile
Gaming-Style Dashboard: The profile screen is designed to look like a character stats page from a modern RPG.
Core Attributes Pentagon: A pentagon chart visually represents your character's core stats (Strength, Intelligence, etc.).
Detailed Activity Log: The profile features an interactive calendar that highlights all your active days, providing a long-term view of your consistency.
Player Vitals: Displays your current level, title, and daily streak count prominently.
Backend & Architecture
Firebase Backend:
Firebase Authentication: Secure email & password-based user sign-up and login.
Cloud Firestore: A scalable NoSQL database used to store all user data, including levels, XP, streaks, and detailed activity logs in a subcollection.
Provider State Management: Leverages the Provider package to manage app state efficiently, separating business logic from the UI.
Clean Project Structure: The code is organized by feature and layer (models, providers, screens, widgets), making it scalable and maintainable.
📸 Screenshots
(Screenshots of the Login Screen, Home Dashboard, Activity Timer, and Profile Screen will be added here soon.)
Login Screen	Home Dashboard
(Image)	(Image)
Activity Timer	Player Profile
(Image)	(Image)
🛠️ Tech Stack & Dependencies
Framework: Flutter
Backend: Firebase Authentication, Cloud Firestore
State Management: Provider
Key Packages:
firebase_core: For connecting to the Firebase project.
cloud_firestore: For database interaction.
firebase_auth: For user authentication.
video_player: For animated background videos.
audioplayers: For sound effects.
flutter_animate: For stunning UI animations.
intl: For date formatting.
🚀 Getting Started
To get a local copy up and running, follow these simple steps.
Prerequisites
Flutter SDK (version 3.0.0 or higher)
A code editor like VS Code or Android Studio.
Installation
Set up a Firebase Project:
Create a new project on the Firebase Console.
Add an Android app to your Firebase project. Follow the on-screen instructions to download the google-services.json file.
Place the google-services.json file in the android/app/ directory of this project.
In the Firebase console, enable Authentication (with Email/Password provider) and Firestore Database.
Clone the repository:
Generated sh
git clone https://github.com/YOUR_USERNAME/level_up_life.git
Use code with caution.
Sh
Navigate to the project directory:
Generated sh
cd level_up_life
Use code with caution.
Sh
Install dependencies:
Generated sh
flutter pub get
Use code with caution.
Sh
Run the app:
Generated sh
flutter run
Use code with caution.
Sh
📲 Release
This project is in active development. An official APK for Android will be released for testing and demonstration purposes soon. Stay tuned!
📜 License
This project is not yet licensed. You are free to explore the code, but please contact the author for permissions regarding distribution or commercial use. An MIT License will likely be added upon the first official release.

