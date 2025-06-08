// lib/models/user_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { strength, intelligence, water, brush, consistency }

class UserData {
  final String uid;
  int level;
  int currentXp;
  int streakCount;
  DateTime? lastActivityDate; // Tracks the last day ANY activity gave XP
  int streakSavers;
  // Timestamps for health validation
  DateTime? lastWaterTime;
  DateTime? lastBrushTime;
  int waterCountToday;

  UserData({
    required this.uid,
    this.level = 1,
    this.currentXp = 0,
    this.streakCount = 0,
    this.lastActivityDate,
    this.streakSavers = 0,
    this.lastWaterTime,
    this.lastBrushTime,
    this.waterCountToday = 0,
  });

  // Method to calculate XP needed for next level (simple version)
  int xpForNextLevel() {
    return 100 + level * 50; // Example: Level 1 needs 150, Level 2 needs 200
  }

  // Factory constructor to create UserData from Firestore snapshot
  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(
      uid: doc.id,
      level: data['level'] ?? 1,
      currentXp: data['currentXp'] ?? 0,
      streakCount: data['streakCount'] ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
      streakSavers: data['streakSavers'] ?? 0,
      lastWaterTime: (data['lastWaterTime'] as Timestamp?)?.toDate(),
      lastBrushTime: (data['lastBrushTime'] as Timestamp?)?.toDate(),
      waterCountToday: data['waterCountToday'] ?? 0,
    );
  }

  // Method to convert UserData to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'currentXp': currentXp,
      'streakCount': streakCount,
      'lastActivityDate': lastActivityDate != null ? Timestamp.fromDate(lastActivityDate!) : null,
      'streakSavers': streakSavers,
      'lastWaterTime': lastWaterTime != null ? Timestamp.fromDate(lastWaterTime!) : null,
      'lastBrushTime': lastBrushTime != null ? Timestamp.fromDate(lastBrushTime!) : null,
      'waterCountToday': waterCountToday,
      // Store last updated time for debugging/potential future use
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}