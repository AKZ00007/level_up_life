// lib/providers/user_data_provider.dart
import 'package:flutter/material.dart'; // <-- Added
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_data.dart';
import '../utils/sound_manager.dart'; // <-- Added
import '../widgets/level_up_popup.dart'; // <-- Added

class UserDataProvider with ChangeNotifier {
  final String? _uid;
  final GlobalKey<NavigatorState> _navigatorKey; // <-- Added
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserData? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor accepts navigatorKey
  UserDataProvider(this._uid, this._navigatorKey);

  bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void loadInitialDataIfNeeded(UserDataProvider? previousProvider) {
    if (_uid != null && (_userData == null || previousProvider?._uid != _uid)) {
      print("Loading initial data for user: $_uid");
      loadUserData();
    } else if (_uid == null) {
      _userData = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserData() async {
    if (_uid == null) {
      _isLoading = false;
      _userData = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_uid).get();

      if (doc.exists) {
        _userData = UserData.fromFirestore(doc);
        print("User data loaded: Level ${_userData?.level}, XP ${_userData?.currentXp}");

        final now = DateTime.now();
        if (!_isSameDay(_userData!.lastActivityDate, now)) {
          _userData!.waterCountToday = 0;
          print("New day detected, resetting daily counts.");
        }
        await _checkDailyStreak();
      } else {
        print("No user data found for $_uid, creating new document.");
        _userData = UserData(uid: _uid);
        await _firestore.collection('users').doc(_uid).set(_userData!.toFirestore());
      }
    } catch (e) {
      print("Error loading user data: $e");
      _errorMessage = "Failed to load user data: $e";
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // XP values
  Map<ActivityType, int> xpValues = {
    ActivityType.strength: 500,
    ActivityType.intelligence: 80,
    ActivityType.water: 500,
    ActivityType.brush: 5,
    ActivityType.consistency: 15,
    // Consider adding ActivityType.dailyLog if you want specific XP for it
  };

  // --- New: Level Names ---
  String _getLevelName(int level) {
    if (level < 5) return "Novice Adventurer";
    if (level < 10) return "Iron Trainee";
    if (level < 15) return "Bronze Warrior";
    if (level < 20) return "Silver Knight";
    if (level < 30) return "Golden Paladin";
    if (level < 40) return "Platinum Guardian";
    if (level < 50) return "Diamond Legend";
    return "Mythic Sovereign";
  }

  Future<void> _addXp(int amount, ActivityType source) async {
    if (_userData == null || _uid == null) return;

    print("Adding $amount XP from ${source.name}");

    _userData!.currentXp += amount;
    bool leveledUp = false;

    // int initialLevel = _userData!.level; // Not used, can be removed

    while (_userData!.currentXp >= _userData!.xpForNextLevel()) {
      leveledUp = true;
      _userData!.currentXp -= _userData!.xpForNextLevel();
      _userData!.level++;
      print("Leveled Up! New Level: ${_userData!.level}");

      if (_userData!.level >= 20 && _userData!.level % 5 == 0) {
        _userData!.streakSavers++;
        print("Awarded Streak Saver! Total: ${_userData!.streakSavers}");
      }
    }

    if (leveledUp) {
      final int newLevel = _userData!.level;
      final String levelName = _getLevelName(newLevel);

      print("Triggering Level Up sequence for Level $newLevel ($levelName)...");

      // Play sound
      SoundManager.playLevelUpSound();

      final currentContext = _navigatorKey.currentContext;
      if (currentContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_navigatorKey.currentContext != null) {
            showDialog(
              context: _navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return LevelUpNotificationPopup(
                  newLevel: newLevel,
                  levelName: levelName,
                );
              },
            );
            print("Level up popup shown.");
          } else {
            print("Error: Navigator context became null before showing dialog.");
          }
        });
      } else {
        print("Error: Cannot show level up dialog - Navigator context is null.");
      }
    }

    if (source != ActivityType.consistency) {
      // Ensure lastActivityDate is updated for non-consistency activities
      // If the activity being logged is for a past date (e.g. from calendar),
      // this logic might need adjustment to not overwrite with DateTime.now()
      // if dateToLog is older. This is handled in logDailyActivity.
       final now = DateTime.now();
      if (_userData!.lastActivityDate == null || now.isAfter(_userData!.lastActivityDate!)) {
        _userData!.lastActivityDate = now;
      }
    }

    await _updateUserDataInFirestore();
  }

  Future<void> completeTimedActivity(ActivityType type) async {
    if (type == ActivityType.strength || type == ActivityType.intelligence) {
      await _addXp(xpValues[type]!, type);
    }
  }

  Future<String?> logWater() async {
    if (_userData == null) return "User data not loaded.";
    final now = DateTime.now();

    if (!_isSameDay(_userData!.lastActivityDate, now)) {
      _userData!.waterCountToday = 0;
    }

    if (_userData!.waterCountToday >= 6) {
      return "Max water (6 glasses) logged for today.";
    }

    if (_userData!.lastWaterTime != null && now.difference(_userData!.lastWaterTime!).inMinutes < 60) {
      int waitMinutes = 60 - now.difference(_userData!.lastWaterTime!).inMinutes;
      return "Too soon! Wait $waitMinutes more minutes.";
    }

    _userData!.lastWaterTime = now;
    _userData!.waterCountToday++;
    await _addXp(xpValues[ActivityType.water]!, ActivityType.water);
    return "Water logged! (${_userData!.waterCountToday}/6)";
  }

  Future<String?> logBrush() async {
    if (_userData == null) return "User data not loaded.";
    final now = DateTime.now();

    if (_userData!.lastBrushTime != null && now.difference(_userData!.lastBrushTime!).inHours < 14) {
      int waitHours = 14 - now.difference(_userData!.lastBrushTime!).inHours;
      return "Too soon! Wait $waitHours more hours.";
    }

    _userData!.lastBrushTime = now;
    await _addXp(xpValues[ActivityType.brush]!, ActivityType.brush);
    return "Brushing logged!";
  }

  Future<void> _checkDailyStreak() async {
    if (_userData == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = _userData!.lastActivityDate;

    if (lastActivity == null) {
      print("No previous activity date found, streak check skipped.");
      // If lastActivityDate is null, but user just logged something,
      // it should be set by _addXp or logDailyActivity.
      // We might want to set streak to 1 if an activity was just logged for today.
      // This part might need refinement based on when _checkDailyStreak is called.
      // For now, if lastActivityDate is still null after an activity, streak remains 0.
      await _updateUserDataInFirestore(); // Ensure data is saved even if no streak change
      return;
    }

    final lastActivityDay = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
    final yesterday = today.subtract(const Duration(days: 1));

    bool streakChanged = false;

    if (_isSameDay(lastActivityDay, yesterday)) {
      print("Streak continues!");
      _userData!.streakCount++;
      await _addXp(xpValues[ActivityType.consistency]!, ActivityType.consistency);
      streakChanged = true;
    } else if (lastActivityDay.isBefore(yesterday)) {
      print("Streak broken! Last activity was on ${DateFormat.yMd().format(lastActivityDay)}");
      if (_userData!.streakSavers > 0) {
        // For now, we just note it. Implementing actual saver use is a separate feature.
        print("Streak Saver available (${_userData!.streakSavers}), but auto-use not implemented yet. Streak reset to 0.");
        _userData!.streakCount = 0;
        // Consider consuming a streak saver here if auto-use was intended:
        // _userData.streakSavers--;
        // _userData.streakCount = 1; // Or maintain old streak
      } else {
        _userData!.streakCount = 0;
        print("No streak savers. Streak reset.");
      }
      streakChanged = true;
    } else if (_isSameDay(lastActivityDay, today)) {
      // If the last activity was today, and it's the first activity, streak should be 1.
      if (_userData!.streakCount == 0) {
        _userData!.streakCount = 1;
         print("First activity of the day. Streak set to 1.");
         // Optionally award consistency XP for starting a streak or first daily activity
         // await _addXp(xpValues[ActivityType.consistency]!, ActivityType.consistency);
         streakChanged = true;
      } else {
        print("Already active today, no streak change based on yesterday's activity.");
      }
    } else {
       print("Last activity was not yesterday or today. No streak change. Current streak: ${_userData!.streakCount}");
    }

    // If _addXp was called for consistency, it already calls _updateUserDataInFirestore.
    // Otherwise, if only streakCount changed, call it.
    if (streakChanged && !(lastActivityDay == yesterday)) { // Avoid double update if consistency XP was given
        await _updateUserDataInFirestore();
    } else if (!streakChanged) {
        // If nothing changed but this method was called, ensure state is consistent.
        // This might be redundant if called from loadUserData where notifyListeners happens at the end.
        // However, better safe.
        // await _updateUserDataInFirestore(); // Potentially remove if causing too many writes
    }
  }

  Future<void> _updateUserDataInFirestore() async {
    if (_uid == null || _userData == null) return;
    try {
      await _firestore.collection('users').doc(_uid).set(_userData!.toFirestore());
      print("User data updated in Firestore: Level ${_userData?.level}, XP ${_userData?.currentXp}, Streak ${_userData?.streakCount}, LastActivity: ${_userData?.lastActivityDate}");
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to save data: $e";
      print("Error saving user data: $e");
      notifyListeners(); // Notify even on error so UI can show errorMessage
    }
  }

  // --- Method for Calendar ---
  Future<Set<String>> getActivitiesForMonth(int year, int month) async {
    if (_uid == null) return {};

    Set<String> markedDays = {};
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    // To get the last moment of the last day of the month
    final DateTime lastDayOfMonthEnd = (month == 12)
        ? DateTime(year + 1, 1, 1).subtract(const Duration(microseconds: 1))
        : DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1));


    // Query the 'activity_logs' subcollection
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('activity_logs')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonthEnd))
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['timestamp'] is Timestamp) {
          final activityTimestamp = (data['timestamp'] as Timestamp).toDate();
          markedDays.add(DateFormat('yyyy-MM-dd').format(activityTimestamp));
        }
      }
      print("Fetched ${markedDays.length} active days for $year-$month from Firestore activity_logs.");
    } catch (e) {
      print("Error fetching activity logs for calendar: $e");
      // Fallback or error handling
    }
    
    // Optionally, include the main lastActivityDate if it's in the month and not already covered
    // This is more of a fallback if activity_logs are not comprehensive
    if (_userData?.lastActivityDate != null) {
      final activityDate = _userData!.lastActivityDate!;
      if (!activityDate.isBefore(firstDayOfMonth) && !activityDate.isAfter(lastDayOfMonthEnd)) {
        markedDays.add(DateFormat('yyyy-MM-dd').format(activityDate));
         print("Added lastActivityDate (${DateFormat('yyyy-MM-dd').format(activityDate)}) to marked days for $year-$month.");
      }
    }


    // For testing if Firestore query yields nothing:
    // if (markedDays.isEmpty && _uid != null) { // Only add dummy data if real query was expected
    //   print("No activity logs found for $year-$month, adding dummy data for testing.");
    //   markedDays.add(DateFormat('yyyy-MM-dd').format(DateTime(year, month, 2)));
    //   markedDays.add(DateFormat('yyyy-MM-dd').format(DateTime(year, month, 5)));
    //   markedDays.add(DateFormat('yyyy-MM-dd').format(DateTime(year, month, 15)));
    // }

    return markedDays;
  }

  // --- New Method for Logging Daily Activity from Calendar ---
  Future<String?> logDailyActivity(DateTime dateToLog) async {
    if (_userData == null || _uid == null) return "User data not loaded.";

    // 1. (Optional) Check if an activity for this specific date has already been logged
    //    to prevent duplicate logging for the same day via this specific function.
    //    This requires a more robust way to store and check activity logs per day.
    //    For now, we'll check the 'activity_logs' subcollection for an entry on this day.
    String dateStringToLog = DateFormat('yyyy-MM-dd').format(dateToLog);
    try {
        final QuerySnapshot existingLogs = await _firestore
            .collection('users')
            .doc(_uid)
            .collection('activity_logs')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(dateToLog.year, dateToLog.month, dateToLog.day)))
            .where('timestamp', isLessThan: Timestamp.fromDate(DateTime(dateToLog.year, dateToLog.month, dateToLog.day).add(const Duration(days:1))))
            .limit(1) // We only need to know if at least one exists
            .get();

        if (existingLogs.docs.isNotEmpty) {
            // Check if any of these logs were 'daily_calendar_log' or a generic log
            // For simplicity, if any log exists, we can prevent re-logging or allow it.
            // Let's assume for now that if any log exists for the day, we don't add another "generic" one.
            // This behavior can be refined.
            bool calendarLogExists = existingLogs.docs.any((doc) => (doc.data() as Map<String,dynamic>)['type'] == 'daily_calendar_log');
            if(calendarLogExists){
                 print("Daily activity already logged for $dateStringToLog via calendar.");
                 return "Activity already logged for ${DateFormat.yMd().format(dateToLog)}.";
            }
        }
    } catch (e) {
        print("Error checking existing daily logs: $e");
        // Decide if to proceed or return error. For now, let's proceed cautiously.
    }


    // 2. Add XP
    const int dailyLogXp = 10; // Example XP
    // Using ActivityType.consistency, or create a new ActivityType.dailyLog
    await _addXp(dailyLogXp, ActivityType.consistency);

    // 3. Update lastActivityDate
    // This should reflect the most recent activity. If logging for a past date,
    // only update if `dateToLog` is more recent than current `lastActivityDate`
    // or if `lastActivityDate` is null.
    // However, `_addXp` updates `lastActivityDate` to `DateTime.now()` if source is not consistency.
    // If source IS consistency (like here), `lastActivityDate` is NOT updated by `_addXp`.
    // So, we need to manage it carefully here.
    // For a "daily log" for a specific `dateToLog`, it makes sense to update `lastActivityDate`
    // if this `dateToLog` is the "latest" activity.
    
    final normalizedDateToLog = DateTime(dateToLog.year, dateToLog.month, dateToLog.day);
    if (_userData!.lastActivityDate == null || normalizedDateToLog.isAfter(_userData!.lastActivityDate!)) {
        _userData!.lastActivityDate = normalizedDateToLog;
         print("Updated lastActivityDate to $normalizedDateToLog from daily log.");
    }


    // 4. Persist this specific activity log to the subcollection.
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('activity_logs')
          .add({
        'timestamp': Timestamp.fromDate(dateToLog), // Use the precise dateToLog
        'type': 'daily_calendar_log',
        'xp_gained': dailyLogXp,
        'description': 'Logged activity from calendar.',
      });
      print("Daily activity logged for ${DateFormat.yMd().format(dateToLog)} in Firestore subcollection.");
    } catch (e) {
      print("Error saving daily activity log to Firestore: $e");
      _errorMessage = "Failed to save activity log: $e";
      notifyListeners();
      return "Failed to save activity log.";
    }

    // 5. Update local streak and user data in Firestore
    // _checkDailyStreak will be called, which considers the new _userData.lastActivityDate.
    // _addXp already called _updateUserDataInFirestore.
    // Calling _checkDailyStreak again ensures streak logic is processed with the potentially updated lastActivityDate.
    await _checkDailyStreak();
    // _updateUserDataInFirestore might be redundant if _checkDailyStreak always calls it,
    // but ensure all changes (like lastActivityDate if not covered by _addXp's call) are saved.
    // Let's ensure one final save.
    await _updateUserDataInFirestore();


    // notifyListeners(); // _updateUserDataInFirestore already calls this.
    return "Activity logged for ${DateFormat.yMd().format(dateToLog)}! +$dailyLogXp XP";
  }

}