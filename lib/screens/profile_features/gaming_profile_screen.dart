//lib/screens/profile_features/gaming_profile_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui; // For ImageFilter
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // For accessing UserDataProvider
import '../../providers/user_data_provider.dart'; // Path to your UserDataProvider
import '../../models/user_data.dart'; // Path to your UserData model

// --- AppColors for this specific profile page ---
// To avoid conflicts, we'll keep these specific to this screen for now.
// You can later decide to merge them into a global AppColors if desired.
class _ProfileAppColors {
  static const Color primaryBlue = Color(0xFF00AFFF); // Brighter Blue
  static const Color primaryBlueDark = Color(0xFF0077B6);
  static const Color accentPurple = Color(0xFF6A0DAD); // Vibrant Purple
  static const Color accentPurpleDark = Color(0xFF4B0082);
  static const Color vibrantCyan = Color(0xFF00FFFF);
  static const Color darkBackground = Color(0xFF0A0A1A); // Very dark blue/purple
  static const Color proTagPurple = Color(0xFF7B1FA2);
  static const Color onlineCyan = Color(0xFF18FFFF);
  static const Color iconPurple = Color(0xFFAB47BC);
}

// --- Main Profile Page Widget to be integrated ---
class GamingProfileScreen extends StatefulWidget {
  const GamingProfileScreen({Key? key}) : super(key: key);

  @override
  State<GamingProfileScreen> createState() => _GamingProfileScreenState();
}

class _GamingProfileScreenState extends State<GamingProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _profileAnimationController;
  final Map<String, double> _pentagonStats = {
    'Strength': 50, // TODO: Get these from UserDataProvider
    'Magic': 60,    // TODO: (Intelligence in your app)
    'Dexterity': 70, // TODO: (Could be agility/speed if you add it)
    'Arcane': 45,   // TODO: (Could be another skill)
    'Vitality': 55, // TODO: (Health/Stamina related)
  };
  final Map<String, Color> _pentagonStatColors = {
    'Strength': const Color(0xFFFF3366),
    'Magic': const Color(0xFF3399FF),
    'Dexterity': const Color(0xFF33CC33),
    'Arcane': const Color(0xFFCC33FF),
    'Vitality': const Color(0xFFFFCC00),
  };
  final double _pentagonMaxStat = 100; // TODO: Adjust as per your game balance

  late int _calendarSelectedYear;
  late int _calendarSelectedMonth;
  Set<String> _calendarMarkedDays = {}; // Will be populated from UserDataProvider

  // User Data related fields
  String _playerName = "Adventurer";
  int _playerLevel = 1;
  int _playerStreak = 0;


  @override
  void initState() {
    super.initState();
    _profileAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    final now = DateTime.now();
    _calendarSelectedYear = now.year;
    _calendarSelectedMonth = now.month;

    // Fetch initial data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadCalendarData();
    });
  }

  void _loadUserData() {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (userDataProvider.userData != null) {
      final user = userDataProvider.userData!;
      setState(() {
        _playerName = "Adventurer"; // You might want to add a name field to UserData
        _playerLevel = user.level;
        _playerStreak = user.streakCount;

        // Example: Populate pentagon stats from UserData if you add corresponding fields
        // For now, we'll keep the defaults and you can adapt this later
        // _pentagonStats['Strength'] = user.strengthStat ?? 50;
        // _pentagonStats['Magic'] = user.intelligenceStat ?? 60; // Assuming 'Magic' maps to Intelligence
      });
    }
  }

  Future<void> _loadCalendarData() async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // This is a placeholder. You'll need to implement getActivitiesForMonth in UserDataProvider
    // For now, it will return an empty set.
    final markedDays = await userDataProvider.getActivitiesForMonth(_calendarSelectedYear, _calendarSelectedMonth);
    if (mounted) {
      setState(() {
        _calendarMarkedDays = markedDays;
      });
    }
  }


  @override
  void dispose() {
    _profileAnimationController.dispose();
    super.dispose();
  }

  void _upgradePentagonAttribute(String attribute) {
    // TODO: This should ideally trigger an update in UserDataProvider
    // and persist the change. For now, it's local UI.
    if (_pentagonStats[attribute]! < _pentagonMaxStat) {
      setState(() {
        _pentagonStats[attribute] =
            (_pentagonStats[attribute]! + 5).clamp(0, _pentagonMaxStat);
      });
    }
  }

  IconData _getPentagonAttributeIcon(String attribute) {
    switch (attribute) {
      case 'Strength':
        return Icons.fitness_center;
      case 'Magic': // Maps to Intelligence
        return Icons.lightbulb_outline; // Changed icon for intelligence
      case 'Dexterity':
        return Icons.speed;
      case 'Arcane':
        return Icons.psychology;
      case 'Vitality':
        return Icons.favorite;
      default:
        return Icons.star;
    }
  }

  // --- Methods for Calendar Feature ---
  void _calendarMarkRandomDay() async { // Make it async
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (userDataProvider.userData == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not available.")),
        );
      }
      return;
    }

    // For this button, let's log an activity for "today"
    DateTime dayToLog = DateTime.now();
    // Or, if you want to pick a random day from the calendar (less practical for logging):
    // int daysInMonth = DateTime(_calendarSelectedYear, _calendarSelectedMonth + 1, 0).day;
    // if (daysInMonth <= 0) return;
    // int randomDayNumber = math.Random().nextInt(daysInMonth) + 1;
    // DateTime dayToLog = DateTime(_calendarSelectedYear, _calendarSelectedMonth, randomDayNumber);

    String? result = await userDataProvider.logDailyActivity(dayToLog);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? "Could not log activity."),
          backgroundColor: result != null && result.startsWith("Activity logged")
              ? Colors.green
              : Colors.redAccent,
        ),
      );
      // After logging, refresh the calendar data to show the new mark
      _loadCalendarData();
    }
  }


  void _calendarPreviousMonth() {
    setState(() {
      if (_calendarSelectedMonth == 1) {
        _calendarSelectedYear--;
        _calendarSelectedMonth = 12;
      } else {
        _calendarSelectedMonth--;
      }
    });
    _loadCalendarData(); // Reload data for the new month
  }

  void _calendarNextMonth() {
    setState(() {
      if (_calendarSelectedMonth == 12) {
        _calendarSelectedYear++;
        _calendarSelectedMonth = 1;
      } else {
        _calendarSelectedMonth++; // Corrected this line
      }
    });
    _loadCalendarData(); // Reload data for the new month
  }

  List<TableRow> _buildCalendarRows() {
    List<TableRow> rows = [];
    rows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.blue.shade900.withOpacity(0.3)),
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            alignment: Alignment.center,
            child: Text('Wk',
                style: TextStyle(color: Colors.blue.shade400, fontSize: 10, fontFamily: 'DEM-MOMono')),
          ),
          for (String day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.blue.shade200,
                      fontWeight: FontWeight.bold,
                      fontSize: 12, fontFamily: 'DEM-MOMono')),
            ),
        ],
      ),
    );

    DateTime firstDayOfMonth =
        DateTime(_calendarSelectedYear, _calendarSelectedMonth, 1);
    DateTime firstDayOfCalendar =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    DateTime currentDayPointer = firstDayOfCalendar;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    for (int week = 0; week < 6; week++) {
      int isoWeekNumber = _getCalendarISOWeekNumber(
          currentDayPointer.add(const Duration(days: 3)));
      List<Widget> cells = [];
      cells.add(
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          margin: const EdgeInsets.only(right: 4.0),
          decoration: BoxDecoration(
              color: Colors.blue.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text('w-$isoWeekNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.blue.shade200,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, fontFamily: 'DEM-MOMono')),
        ),
      );

      for (int i = 0; i < 7; i++) {
        DateTime cellDate = currentDayPointer;
        DateTime normalizedCellDate =
            DateTime(cellDate.year, cellDate.month, cellDate.day);
        bool isCurrentMonth = cellDate.month == _calendarSelectedMonth &&
            cellDate.year == _calendarSelectedYear;
        String dateString = DateFormat('yyyy-MM-dd').format(cellDate);
        bool isMarked = _calendarMarkedDays.contains(dateString);
        bool isToday = normalizedCellDate.isAtSameMomentAs(todayDate);
        Color dayColor = Colors.grey.shade600;
        if (isCurrentMonth) {
          dayColor = isMarked
              ? Colors.white
              : (isToday ? Colors.blue.shade200 : Colors.grey.shade400);
        }

        cells.add(
          Container(
            height: 40,
            alignment: Alignment.center,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCurrentMonth && isMarked
                    ? Colors.blue.shade700
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: isToday
                        ? Colors.blue.shade400
                        : (isCurrentMonth
                            ? (isMarked
                                ? Colors.transparent
                                : Colors.grey.shade800)
                            : Colors.transparent),
                    width: isToday ? 1.5 : (isCurrentMonth ? 1 : 0)),
                boxShadow: isCurrentMonth && isMarked
                    ? [
                        BoxShadow(
                            color: Colors.blue.shade500.withOpacity(0.7),
                            blurRadius: 8,
                            spreadRadius: 1)
                      ]
                    : null,
              ),
              child: Center(
                  child: Text('${cellDate.day}',
                      style: TextStyle(
                          color: dayColor,
                          fontSize: 10,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'DEM-MOMono'
                        )
                    )
                ),
            ),
          ),
        );
        currentDayPointer = currentDayPointer.add(const Duration(days: 1));
      }
      rows.add(TableRow(children: cells));
      DateTime nextWeekStartDate = currentDayPointer;
      DateTime lastDayOfMonth =
          DateTime(_calendarSelectedYear, _calendarSelectedMonth + 1, 0);
      if (nextWeekStartDate.isAfter(lastDayOfMonth) && week >= 4) break;
    }
    return rows;
  }

  int _getCalendarISOWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekday = date.weekday;
    int weekNumber = ((dayOfYear - weekday + 10) / 7).floor();
    if (weekNumber < 1) {
      return _getCalendarISOWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    if (weekNumber == 53) {
      DateTime firstDayOfYear = DateTime(date.year, 1, 1);
      DateTime lastDayOfYear = DateTime(date.year, 12, 31);
      if (firstDayOfYear.weekday != DateTime.thursday &&
          lastDayOfYear.weekday != DateTime.thursday) return 1;
    }
    return weekNumber;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to UserDataProvider for real-time updates
    // This ensures the UI rebuilds if _loadUserData is called due to provider changes
    Provider.of<UserDataProvider>(context);

    return Theme( // Apply DEM-MOMono font specifically to this screen's context if needed
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'DEM-MOMono'),
      ),
      child: Scaffold(
        // appBar: AppBar( // Optional: Add an AppBar if you want a title for the profile page
        //   title: Text('Profile', style: TextStyle(fontFamily: 'DEM-MOMono')),
        //   backgroundColor: _ProfileAppColors.darkBackground,
        // ),
        backgroundColor: _ProfileAppColors.darkBackground, // Use specific background
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _profileAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GridPainter(_profileAnimationController.value),
                  );
                },
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildNexusGamingHeader(),
                    const SizedBox(height: 20),
                    ProfileCard(
                        playerName: _playerName,
                        level: _playerLevel,
                        streak: _playerStreak,
                    ),
                    const SizedBox(height: 30),
                    _buildPentagonProfileHeader(),
                    const SizedBox(height: 24),
                    _buildPentagonStatsSection(),
                    const SizedBox(height: 24),
                    _buildPentagonUpgradeButtonsSection(),
                    const SizedBox(height: 30),
                    _buildCalendarSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNexusGamingHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_moon_outlined, color: _ProfileAppColors.primaryBlue, size: 28), // Changed icon
          const SizedBox(width: 10),
          Text(
            "PLAYER PROFILE", // Changed title
            style: TextStyle(
              color: _ProfileAppColors.primaryBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontFamily: 'DEM-MOMono',
              shadows: [
                Shadow(
                    color: _ProfileAppColors.primaryBlueDark.withOpacity(0.7),
                    blurRadius: 10),
                Shadow(
                    color: _ProfileAppColors.accentPurple.withOpacity(0.5),
                    blurRadius: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPentagonProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            Colors.black,
            const Color(0xFF0A1622)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF0066CC)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0088FF).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0066CC), Color(0xFF001133)]),
              border: Border.all(color: const Color(0xFF00CCFF), width: 2),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF00CCFF).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2)
              ],
            ),
            // TODO: Use player avatar if available
            child: Center(
                child: Icon(Icons.person_pin_circle_outlined,
                    size: 40,
                    color: Color(0xFFBBDEFF))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00CCFF), Color(0xFF0088FF)])
                      .createShader(bounds),
                  child: Text(_playerName.toUpperCase(), // Use dynamic player name
                      style: TextStyle(
                          fontSize: 20, // Adjusted size
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DEM-MOMono',
                          color: Colors.white)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF003366),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('LVL $_playerLevel', // Use dynamic level
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00CCFF),
                              fontFamily: 'DEM-MOMono',
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    // TODO: Could show Rank based on level or other metrics
                    Text('HERO TIER', // Placeholder
                        style: TextStyle(color: Color(0xFFFFCC00), fontSize: 12, fontFamily: 'DEM-MOMono')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPentagonStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066CC)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0088FF).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00CCFF), Color(0xFF0088FF)])
                .createShader(bounds),
            child: Text('CORE ATTRIBUTES', // Changed title
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DEM-MOMono',
                    color: Colors.white)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: PentagonStatsChart(
                stats: _pentagonStats, // TODO: These should come from UserData
                maxStat: _pentagonMaxStat,
                statColors: _pentagonStatColors),
          ),
        ],
      ),
    );
  }

  Widget _buildPentagonUpgradeButtonsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0066CC)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0088FF).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00CCFF), Color(0xFF0088FF)])
                .createShader(bounds),
            child: Text('ENHANCE ATTRIBUTES', // Changed title
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DEM-MOMono',
                    color: Colors.white)),
          ),
          const SizedBox(height: 16),
          ..._pentagonStats.keys
              .map((attribute) => _buildPentagonAttributeButton(attribute))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPentagonAttributeButton(String attribute) {
    final bool isMaxed = _pentagonStats[attribute]! >= _pentagonMaxStat;
    // TODO: Actual upgrade logic should go into UserDataProvider
    // For now, tapping this button is visual only.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isMaxed ? null : () => _upgradePentagonAttribute(attribute),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A1622),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isMaxed
                      ? const Color(0xFF0066CC).withOpacity(0.5)
                      : const Color(0xFF0066CC)),
              boxShadow: [
                BoxShadow(
                    color: _pentagonStatColors[attribute]!.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1)
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black,
                          _pentagonStatColors[attribute]!.withOpacity(0.3)
                        ]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getPentagonAttributeIcon(attribute),
                      color: _pentagonStatColors[attribute], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Text(attribute == 'Magic' ? 'Intelligence' : attribute, // Map "Magic" to "Intelligence" for display
                        style: TextStyle(
                            color: const Color(0xFF00CCFF),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'DEM-MOMono',
                            fontSize: 16))),
                Text('${_pentagonStats[attribute]!.toInt()}/$_pentagonMaxStat',
                    style: TextStyle(
                        color: const Color(0xFF00CCFF), fontFamily: 'DEM-MOMono', fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: isMaxed
                          ? const Color(0xFF003366).withOpacity(0.5)
                          : const Color(0xFF003366),
                      shape: BoxShape.circle),
                  child: Icon(Icons.add,
                      color: isMaxed
                          ? const Color(0xFF00CCFF).withOpacity(0.5)
                          : const Color(0xFF00CCFF),
                      size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 30),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            border: Border.all(color: Colors.blue.shade500, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.shade400.withOpacity(0.6),
                  blurRadius: 18,
                  spreadRadius: 4)
            ],
          ),
          child: Text(
            "DAILY ACTIVITY LOG",
            style: TextStyle(
              color: Colors.blue.shade100,
              fontSize: 22, // Adjusted size
              fontWeight: FontWeight.bold,
              fontFamily: 'DEM-MOMono',
              letterSpacing: 3, // Adjusted spacing
              shadows: [
                Shadow(
                    blurRadius: 15.0,
                    color: Colors.blue.shade300,
                    offset: const Offset(0, 0))
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border.all(color: Colors.blue.shade700, width: 2),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.shade800.withOpacity(0.6),
                  blurRadius: 18,
                  spreadRadius: 3)
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.chevron_left,
                            color: Colors.blue.shade300, size: 32),
                        onPressed: _calendarPreviousMonth,
                        splashRadius: 28),
                    Flexible(
                      child: Text(
                        DateFormat('MMMM yyyy').format(DateTime(
                            _calendarSelectedYear, _calendarSelectedMonth)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 20, // Adjusted size
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DEM-MOMono',
                            letterSpacing: 1.8),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.chevron_right,
                            color: Colors.blue.shade300, size: 32),
                        onPressed: _calendarNextMonth,
                        splashRadius: 28),
                  ],
                ),
              ),
              Divider(
                  color: Colors.blue.shade800.withOpacity(0.6),
                  thickness: 1,
                  height: 25),
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(44),
                  1: FlexColumnWidth(), 2: FlexColumnWidth(),
                  3: FlexColumnWidth(), 4: FlexColumnWidth(),
                  5: FlexColumnWidth(), 6: FlexColumnWidth(),
                  7: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: _buildCalendarRows(),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.shade500.withOpacity(0.8),
                  blurRadius: 16,
                  spreadRadius: 4,
                  offset: const Offset(0, 3))
            ],
          ),
          child: ElevatedButton(
            onPressed: _calendarMarkRandomDay, // Now uses the updated method
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), // Adjusted padding
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.blue.shade300, width: 1.5)),
              elevation: 8,
            ),
            child: const Text("LOG ACTIVITY (TODAY)", // Updated text
                style: TextStyle(
                    fontSize: 15, // Adjusted size
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DEM-MOMono',
                    letterSpacing: 2.0)), // Adjusted spacing
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 30),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjusted padding
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border.all(color: Colors.blue.shade600, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "ACTIVE DAYS LOGGED: ${_calendarMarkedDays.length}",
            style: TextStyle(
                color: Colors.blue.shade200,
                fontWeight: FontWeight.bold,
                fontSize: 14, // Adjusted size
                fontFamily: 'DEM-MOMono',
                letterSpacing: 1.5),
          ),
        ),
      ],
    );
  }
}

// --- GridPainter (from Profile V1) ---
class GridPainter extends CustomPainter {
  final double animationValue;
  GridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = _ProfileAppColors.primaryBlueDark.withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final secondaryPaint = Paint()
      ..color = _ProfileAppColors.accentPurpleDark.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final glowPaint = Paint()
      ..color = _ProfileAppColors.vibrantCyan.withOpacity(0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    double offset = 20 * animationValue;
    for (double y = -offset; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), primaryPaint);
      if (y % 40 == 0) {
        canvas.drawLine(
            Offset(0, y + 5), Offset(size.width, y + 5), secondaryPaint);
      }
    }
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), primaryPaint);
      if (x % 40 == 0) {
        canvas.drawLine(
            Offset(x + 5, 0), Offset(x + 5, size.height), secondaryPaint);
      }
    }
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 150.0 + 50.0 * math.sin(animationValue * 2 * math.pi);
    canvas.drawCircle(center, radius, glowPaint);
    final cornerPaint = Paint()
      ..color = _ProfileAppColors.vibrantCyan.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    const cornerSize = 20.0;
    canvas.drawLine(const Offset(0, cornerSize), const Offset(0, 0), cornerPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(cornerSize, 0), cornerPaint);
    canvas.drawLine(
        Offset(size.width - cornerSize, 0), Offset(size.width, 0), cornerPaint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerSize), cornerPaint);
    canvas.drawLine(Offset(0, size.height - cornerSize), Offset(0, size.height),
        cornerPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerSize, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width - cornerSize, size.height),
        Offset(size.width, size.height), cornerPaint);
    canvas.drawLine(Offset(size.width, size.height - cornerSize),
        Offset(size.width, size.height), cornerPaint);
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;
}

// --- ProfileCard and related Widgets (from Profile V1) ---
class ProfileCard extends StatelessWidget {
  final String playerName;
  final int level;
  final int streak;

  const ProfileCard({
    Key? key,
    required this.playerName,
    required this.level,
    required this.streak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0), // Adjusted margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: _ProfileAppColors.accentPurple.withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: 3),
          BoxShadow(
              color: _ProfileAppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _ProfileAppColors.darkBackground.withOpacity(0.85),
                    _ProfileAppColors.accentPurpleDark.withOpacity(0.5),
                    _ProfileAppColors.primaryBlueDark.withOpacity(0.4)
                  ],
                  stops: const [
                    0.0,
                    0.6,
                    1.0
                  ]),
              border: Border.all(
                  color: _ProfileAppColors.vibrantCyan.withOpacity(0.6), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileImageWithGlow(level: level), // Pass level
                      const SizedBox(width: 16),
                      Expanded(child: UserDetailsCard(
                        playerName: playerName, // Pass player name
                        level: level, // Pass level
                        streak: streak, // Pass streak
                        title: "Voidwalker", // Placeholder
                        rank: "S+", // Placeholder
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Removed action buttons as they might not fit Level Up Life's context directly
                  // You can add relevant actions here later if needed.
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileImageWithGlow extends StatelessWidget {
  final int level;
  const ProfileImageWithGlow({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _ProfileAppColors.primaryBlue.withOpacity(0.8),
                  _ProfileAppColors.accentPurpleDark.withOpacity(0)
                ], stops: const [
                  0.6,
                  1.0
                ]))),
        SizedBox(
          width: 100,
          height: 100,
          child: ClipPath(
            clipper: HexagonClipper(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                          _ProfileAppColors.primaryBlueDark,
                          _ProfileAppColors.accentPurple
                        ])),
                    // TODO: Could use an actual avatar image if you have one
                    child: const Icon(Icons.account_circle,
                        size: 50, color: Colors.white70)),
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomPaint(painter: HexagonBorderPainter())),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(0.6),
                      _ProfileAppColors.accentPurpleDark.withOpacity(0.8)
                    ])),
                    alignment: Alignment.center,
                    child: Text("LVL $level", // Use dynamic level
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'DEM-MOMono',
                            shadows: [
                              Shadow(
                                  color: _ProfileAppColors.vibrantCyan, blurRadius: 5)
                            ])),
                  ),
                ),
                // Removed camera icon as profile image upload isn't standard for Level Up Life yet
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: _ProfileAppColors.accentPurple,
                shape: BoxShape.circle,
                border: Border.all(color: _ProfileAppColors.vibrantCyan, width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: _ProfileAppColors.accentPurple.withOpacity(0.7),
                      blurRadius: 8)
                ]),
            // TODO: Could show a rank icon or similar based on level
            child:
                const Icon(Icons.star, color: Colors.amber, size: 14),
          ),
        ),
      ],
    );
  }
}

class HexagonBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = _ProfileAppColors.vibrantCyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final path = HexagonClipper().getClip(size);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldReclip(CustomPainter oldDelegate) => false;
  @override
  bool shouldRepaint(covariant HexagonBorderPainter oldDelegate) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    path.moveTo(centerX + radius * math.cos(0), centerY + radius * math.sin(0));
    for (int i = 1; i <= 6; i++) {
      double angle = (math.pi / 3) * i;
      path.lineTo(centerX + radius * math.cos(angle),
          centerY + radius * math.sin(angle));
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class UserDetailsCard extends StatelessWidget {
  final String playerName;
  final int level;
  final String rank;
  final String title;
  final int streak;

  const UserDetailsCard(
      {Key? key,
      required this.playerName,
      required this.level,
      required this.rank,
      required this.title,
      required this.streak})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine Level Name based on your existing logic
    String levelName = "Novice Adventurer"; // Default
    if (level >= 50) levelName = "Mythic Sovereign";
    else if (level >= 40) levelName = "Diamond Legend";
    else if (level >= 30) levelName = "Platinum Guardian";
    else if (level >= 20) levelName = "Golden Paladin";
    else if (level >= 15) levelName = "Silver Knight";
    else if (level >= 10) levelName = "Bronze Warrior";
    else if (level >= 5) levelName = "Iron Trainee";


    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ProfileAppColors.darkBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _ProfileAppColors.accentPurpleDark.withOpacity(0.7), width: 1),
        boxShadow: [
          BoxShadow(
              color: _ProfileAppColors.accentPurpleDark.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TechBar(),
          Row(children: [
            Expanded(
                child: Text(playerName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'DEM-MOMono',
                        shadows: [
                          Shadow(color: _ProfileAppColors.primaryBlue, blurRadius: 10)
                        ]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1)),
            const SizedBox(width: 8),
            // Removed "PRO" tag, can be re-added if you have a premium system
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text("Title: ",
                style: TextStyle(
                    color: _ProfileAppColors.primaryBlue.withOpacity(0.8),
                    fontFamily: 'DEM-MOMono',
                    fontSize: 13)),
            Expanded(
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _ProfileAppColors.accentPurple,
                          _ProfileAppColors.primaryBlueDark
                        ]),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                              color: _ProfileAppColors.primaryBlue.withOpacity(0.5),
                              blurRadius: 4)
                        ]),
                    child: Text(levelName, // Use dynamic level name
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DEM-MOMono',
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text("Rank: ",
                style: TextStyle(
                    color: _ProfileAppColors.primaryBlue.withOpacity(0.8),
                    fontFamily: 'DEM-MOMono',
                    fontSize: 14)),
            Icon(Icons.military_tech_outlined, color: _ProfileAppColors.iconPurple, size: 16), // Changed icon
            const SizedBox(width: 2),
            Expanded(
                child: Text(rank, // Placeholder, can be derived from level
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'DEM-MOMono'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1)),
          ]),
          const SizedBox(height: 4),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text("Streak: ",
                  style: TextStyle(
                      color: _ProfileAppColors.primaryBlue.withOpacity(0.8),
                      fontFamily: 'DEM-MOMono',
                      fontSize: 14)),
              Expanded(
                  child: Text("$streak days",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500, fontFamily: 'DEM-MOMono'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1)),
              const SizedBox(width: 4),
              Text("🔥",
                  style: TextStyle(fontSize: 14, shadows: [
                    Shadow(color: Colors.orange.withOpacity(0.7), blurRadius: 5)
                  ])),
            ]),
            const SizedBox(height: 4),
            // Streak progress bar can be adjusted based on some goal
            ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                                colors: [
                              _ProfileAppColors.primaryBlue,
                              _ProfileAppColors.accentPurple
                            ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight)
                            .createShader(bounds),
                    child: LinearProgressIndicator(
                        value: (streak % 30) / 30, // Example: progress within a 30-day cycle
                        backgroundColor: Colors.grey.shade800.withOpacity(0.5),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4))),
          ]),
          const SizedBox(height: 8),
          Center(
              child: PulseAnimation(
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            _ProfileAppColors.onlineCyan.withOpacity(0.8),
                            _ProfileAppColors.onlineCyan.withOpacity(0.5)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: _ProfileAppColors.onlineCyan.withOpacity(0.5),
                                blurRadius: 6)
                          ]),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(color: Colors.white, blurRadius: 3)
                                ])),
                        const SizedBox(width: 6),
                        Text("ONLINE", // Placeholder, can be dynamic
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DEM-MOMono',
                                fontSize: 12))
                      ])))),
        ],
      ),
    );
  }
}

class TechBar extends StatefulWidget {
  const TechBar({Key? key}) : super(key: key);
  @override
  State<TechBar> createState() => _TechBarState();
}

class _TechBarState extends State<TechBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.only(bottom: 10),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              _ProfileAppColors.vibrantCyan.withOpacity(_animation.value),
              _ProfileAppColors.primaryBlue.withOpacity(_animation.value * 0.7)
            ]),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                  color:
                      _ProfileAppColors.vibrantCyan.withOpacity(_animation.value * 0.6),
                  blurRadius: 8)
            ],
          ),
        ),
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  const PulseAnimation({Key? key, required this.child}) : super(key: key);
  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) =>
            Transform.scale(scale: _animation.value, child: widget.child));
  }
}

// --- Pentagon Chart Widgets (from Pentagon feature) ---
class PentagonStatsChart extends StatelessWidget {
  final Map<String, double> stats;
  final Map<String, Color> statColors;
  final double maxStat;

  const PentagonStatsChart({
    Key? key,
    required this.stats,
    required this.maxStat,
    required this.statColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: PentagonPainter(
          stats: stats,
          maxStat: maxStat,
          statColors: statColors),
    );
  }
}

class PentagonPainter extends CustomPainter {
  final Map<String, double> stats;
  final Map<String, Color> statColors;
  final double maxStat;

  PentagonPainter(
      {required this.stats,
      required this.maxStat,
      required this.statColors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    _drawGridLines(canvas, center, radius);
    _drawMaxPentagon(canvas, center, radius);
    _drawStatsPentagon(canvas, center, radius);
    _drawLabels(canvas, center, radius);
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF0066CC).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int level = 1; level <= 5; level++) {
      final path = Path();
      final ratio = level / 5;
      for (int i = 0; i < 5; i++) {
        final angle = (2 * math.pi * i / 5) - (math.pi / 2);
        final point = Offset(center.dx + radius * ratio * math.cos(angle),
            center.dy + radius * ratio * math.sin(angle));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    for (int i = 0; i < 5; i++) {
      final angle = (2 * math.pi * i / 5) - (math.pi / 2);
      final point = Offset(center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle));
      canvas.drawLine(center, point, paint);
    }
  }

  void _drawMaxPentagon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF0066CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (2 * math.pi * i / 5) - (math.pi / 2);
      final point = Offset(center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, paint);
    paint.maskFilter = null;
    canvas.drawPath(path, paint);
  }

  void _drawStatsPentagon(Canvas canvas, Offset center, double radius) {
    final attributes = ['Strength', 'Magic', 'Dexterity', 'Arcane', 'Vitality'];
    final fillPaint = Paint()
      ..color = _ProfileAppColors.primaryBlue.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = _ProfileAppColors.vibrantCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (2 * math.pi * i / 5) - (math.pi / 2);
      final statValue = stats[attributes[i]] ?? 0.0; // Handle null case
      final ratio = (statValue / maxStat).clamp(0.0, 1.0); // Ensure ratio is valid
      final point = Offset(center.dx + radius * ratio * math.cos(angle),
          center.dy + radius * ratio * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    strokePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    strokePaint.maskFilter = null;
    canvas.drawPath(path, strokePaint);
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final attributes = ['Strength', 'Magic', 'Dexterity', 'Arcane', 'Vitality'];
    for (int i = 0; i < 5; i++) {
      final String currentAttribute = attributes[i];
      final String displayName = currentAttribute == 'Magic' ? 'Intelligence' : currentAttribute;
      final Color labelColor = statColors[currentAttribute] ??
          _ProfileAppColors.vibrantCyan;

      final textStyle = TextStyle(
        color: labelColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'DEM-MOMono',
        shadows: [
          Shadow(
              color: labelColor.withOpacity(0.7),
              offset: const Offset(0, 0),
              blurRadius: 4)
        ],
      );
      final angle = (2 * math.pi * i / 5) - (math.pi / 2);
      final labelOffset = Offset(center.dx + (radius + 25) * math.cos(angle),
          center.dy + (radius + 25) * math.sin(angle));
      final textSpan = TextSpan(text: displayName, style: textStyle);
      final textPainter = TextPainter(
          text: textSpan,
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.center);
      textPainter.layout();
      final xOffset = -textPainter.width / 2;
      final yOffset = -textPainter.height / 2;
      final adjustedX =
          labelOffset.dx + xOffset + (i == 1 ? 10 : (i == 4 ? -10 : 0));
      final adjustedY = labelOffset.dy +
          yOffset +
          (i == 0 ? -10 : (i == 2 || i == 3 ? 10 : 0));
      textPainter.paint(canvas, Offset(adjustedX, adjustedY));
    }
  }

  @override
  bool shouldRepaint(PentagonPainter oldDelegate) =>
      oldDelegate.stats != stats ||
      oldDelegate.maxStat != maxStat ||
      oldDelegate.statColors != statColors;
}