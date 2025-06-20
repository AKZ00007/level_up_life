# Level Up Life

> Level Up Life is a mobile application built with Flutter that transforms self-improvement into a captivating role-playing game.  
> Instead of just ticking off tasks, you'll earn experience points (XP), gain levels, and enhance your character's stats by completing real-life activities.  
> This project is currently in active development.

---

## 📽 Demo Video

[Click here to watch the demo](https://drive.google.com/file/d/1rk2hZ10f7D2Yte1DW12k0GBXjRnj2egC/preview)

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [📸 Screenshots](#-screenshots)
- [🛠️ Tech Stack & Dependencies](#️-tech-stack--dependencies)
- [🚀 Getting Started](#-getting-started)
- [📲 Release](#-release)
- [📜 License](#-license)

---

## ✨ Features

### 🎮 Gamified Progression System

- **Experience & Leveling**: Gain XP for every completed activity. Watch your character level up and become more powerful.
- **Dynamic XP Curve**: XP needed for each level increases dynamically for a balanced challenge.
- **Epic Level-Up Notifications**: Custom-animated, sci-fi-themed popups with sound effects celebrate level-ups.
- **Character Ranks**: Advance from "Novice Adventurer" to "Mythic Sovereign" with new titles at milestone levels.
- **Streak System**: Build daily streaks to earn consistency XP.
- **Streak Savers**: Protect your streaks with special "Streak Saver" rewards every 5 levels after level 20.

### ✅ Activity & Habit Tracking

- **Timed Activities**:
  - **Strength & Intelligence**: Train with a sci-fi timer. XP awarded only on completion.
  - **Sub-Activity Selection**: Choose specific workouts or mental tasks (e.g., "Warrior's Workout", "Mind Quest").

- **Health Habits**:
  - **Water Intake**: Track daily water with cooldown timers.
  - **Dental Hygiene**: Log brushing with cooldown to prevent abuse.

- **Daily Activity Calendar**:
  - View logged activities per day on a calendar, backed by Firestore data.

### 🧑‍🚀 Immersive User Interface

- **Futuristic Dark Theme**: Neon glows, animated video backgrounds, sci-fi styling.
- **Custom Animations**: Built with `flutter_animate` and custom painters.
- **Sound Effects**: Integrated `SoundManager` handles level-up, button, and success sounds.
- **Custom Widgets**: Circular timers, progress bars, and stylized UI elements.

### 🧙‍♂️ Advanced Player Profile

- **Gaming-Style Dashboard**: RPG-like character stats screen.
- **Core Attributes Pentagon**: Radar chart showing Strength, Intelligence, etc.
- **Activity Calendar**: Interactive and color-coded for consistency tracking.
- **Player Vitals**: Level, rank, and daily streaks front and center.

---

## 🛠️ Backend & Architecture

### 🔥 Firebase Backend

- **Authentication**: Email/password signup/login.
- **Cloud Firestore**: Stores levels, XP, streaks, logs in scalable subcollections.

### 🧠 State Management

- **Provider**: Cleanly separates logic from UI using the Provider pattern.
- **Clean Architecture**: Codebase is structured by feature (`models/`, `providers/`, `widgets/`, `screens/`).

---

## 📸 Screenshots

_Screenshots of the Login Screen, Home Dashboard, Activity Timer, and Profile Screen will be added here soon._

| Login Screen | Home Dashboard |
|--------------|----------------|
| *(Image)*    | *(Image)*      |

| Activity Timer | Player Profile |
|----------------|----------------|
| *(Image)*      | *(Image)*      |

---

## 🛠️ Tech Stack & Dependencies

### 🔧 Framework
- **Flutter**

### 🔙 Backend
- **Firebase Authentication**
- **Cloud Firestore**

### 🔁 State Management
- **Provider**

### 📦 Key Packages

- `firebase_core`: Firebase initialization
- `cloud_firestore`: Firestore DB
- `firebase_auth`: Auth management
- `video_player`: Background video support
- `audioplayers`: Sound effects
- `flutter_animate`: Advanced animations
- `intl`: Date formatting

---

## 🚀 Getting Started

To run the project locally:

### ✅ Prerequisites

- Flutter SDK (`v3.0.0` or higher)
- Code editor (VS Code / Android Studio)

### 🛠️ Installation

1. **Set up Firebase:**
   - Create a project in [Firebase Console](https://console.firebase.google.com/)
   - Add Android app → download `google-services.json`
   - Place it in `android/app/`
   - Enable Email/Password auth and Firestore in Firebase

2. **Clone the repo:**
   ```sh
   git clone https://github.com/YOUR_USERNAME/level_up_life.git
   cd level_up_life

3. **Install dependencies:**
   ```sh
   flutter pub get

4. **Run the app:**
   ```sh
   flutter run



## 📲 Release

This project is in active development.  
An official APK for Android will be released soon for testing and demonstration purposes. Stay tuned!

---

## 📜 License

This project is **not yet licensed**.  
You are free to explore the code, but please contact the author for permissions regarding distribution or commercial use.


