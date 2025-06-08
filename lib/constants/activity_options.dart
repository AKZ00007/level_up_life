// lib/constants/activity_options.dart (NEW FILE)
import 'package:flutter/material.dart';
import 'package:level_up_life/models/user_data.dart'; // Import your ActivityType enum

class ActivityOption {
  final String name;
  final IconData icon;

  const ActivityOption({required this.name, required this.icon});
}

const Map<ActivityType, List<ActivityOption>> activityOptions = {
  ActivityType.strength: [
    ActivityOption(name: "Warrior's Workout", icon: Icons.fitness_center), // Exercise
    ActivityOption(name: "Zen Flex", icon: Icons.self_improvement), // Yoga
    ActivityOption(name: "Beast Mode", icon: Icons.directions_run), // Calisthenics
    ActivityOption(name: "Power Surge", icon: Icons.flash_on), // HIIT
    ActivityOption(name: "Titan Training", icon: Icons.line_weight), // Heavy Lifting
    ActivityOption(name: "Core Forge", icon: Icons.accessibility_new), // Core
    ActivityOption(name: "Agility Trials", icon: Icons.transfer_within_a_station), // Mobility
  ],
  ActivityType.intelligence: [
    ActivityOption(name: "Mind Quest", icon: Icons.menu_book), // Reading
    ActivityOption(name: "Scholar's Path", icon: Icons.school), // Studying
    ActivityOption(name: "Project Forge", icon: Icons.build), // Projects
    ActivityOption(name: "Wisdom Hunt", icon: Icons.search), // Research
    ActivityOption(name: "Logic Battles", icon: Icons.computer), // Problem-solving/Coding
    ActivityOption(name: "Brain Builder", icon: Icons.extension), // Puzzles/Memory
    ActivityOption(name: "Codex Mastery", icon: Icons.library_books), // Learning New Skills
  ],
};

// Helper to get a friendly name for the main type
String getActivityTypeName(ActivityType type) {
  switch (type) {
    case ActivityType.strength:
      return "Strength Training 🛡️";
    case ActivityType.intelligence:
      return "Intelligence Building 🧠";
    default:
      return "Activity"; // Fallback
  }
}