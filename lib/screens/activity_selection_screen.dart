// lib/screens/activity_selection_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // Make sure this is imported at the top
import 'package:level_up_life/models/user_data.dart'; // Your ActivityType enum
import '../constants/activity_options.dart'; // Import the options and helper
import 'activity_timer_screen.dart'; // Import the timer screen
import '../utils/sound_manager.dart'; // <-- IMPORT SOUND MANAGER

// --- New Dark Color Palette ---
const Color primaryBlueDark = Color(0xFF1A237E); // Indigo 900
const Color accentPurpleDark = Color(0xFF311B92); // Deep Purple 900
const Color highlightBlue = Color(0xFF2962FF); // Blue Accent 700
const Color highlightPurple = Color(0xFF6200EA); // Deep Purple Accent 700
const Color darkBackgroundStart = Color(0xFF020412);
const Color darkBackgroundEnd = Color(0xFF060929);
const Color textWhite = Colors.white;
// --- End of New Color Palette ---

class ActivitySelectionScreen extends StatelessWidget {
  final ActivityType activityType;
  final Duration duration; // Pass the duration through

  const ActivitySelectionScreen({
    super.key,
    required this.activityType,
    required this.duration,
  });

  // Helper method to build the themed AppBar
  Widget _buildThemedAppBar(BuildContext context, String title) {
    final Color appBarIconBgColor = highlightBlue.withOpacity(0.15);
    final Color appBarIconBorderColor = highlightBlue.withOpacity(0.7);
    final Color appBarIconGlowColor = highlightBlue.withOpacity(0.6);
    final Color titleGlowColor = highlightPurple.withOpacity(0.8);

    return Container(
      height: 80, // Or adjust as needed
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back Button Container - Make it tappable
          InkWell( // Wrap with InkWell or GestureDetector for tap
            onTap: () {
              SoundManager.playClickSound(); // Add sound on back press
              Navigator.of(context).pop(); // Actual back navigation
            },
            borderRadius: BorderRadius.circular(12), // Match decoration rounding
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appBarIconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: appBarIconBorderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appBarIconGlowColor,
                    blurRadius: 12,
                    spreadRadius: 3,
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: textWhite,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title Text with Glow
          Expanded( // Use Expanded to prevent overflow if title is long
            child: Text(
              'Select $title Activity', // Use the dynamic title passed in
              style: TextStyle(
                color: textWhite,
                fontSize: 20, // Adjusted size slightly
                fontWeight: FontWeight.bold,
                fontFamily: 'DEM-MOMono', // Use specified font
                shadows: [
                  Shadow(
                    color: titleGlowColor,
                    blurRadius: 14,
                  ),
                  Shadow(
                    color: titleGlowColor.withOpacity(0.6),
                    blurRadius: 20,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis, // Handle long titles
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Get the list of specific activities for the given type (Original Logic)
    final List<ActivityOption>? options = activityOptions[activityType];
    final String title = getActivityTypeName(activityType); // Get friendly title (Original Logic)

    // Handle cases where options might be unexpectedly null (Original Logic)
    if (options == null || options.isEmpty) {
      return Scaffold(
        backgroundColor: darkBackgroundStart, // Use new bg color
        appBar: AppBar(
          title: const Text('Error', style: TextStyle(fontFamily: 'DEM-MOMono', color: textWhite)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: textWhite), // Ensure back arrow is white
        ),
        body: const Center(child: Text(
            'No activities defined for this category.',
            style: TextStyle(color: textWhite, fontFamily: 'DEM-MOMono'))
        ),
      );
    }

    // List of highlight colors using the dark palette (New UI Logic)
    final List<Color> highlightColors = [
      highlightBlue,
      highlightPurple,
      primaryBlueDark,
      accentPurpleDark,
      highlightBlue.withOpacity(0.8),
      highlightPurple.withOpacity(0.8),
    ];

    return Scaffold(
      // Background now uses the very dark gradient (New UI Logic)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              darkBackgroundStart,
              darkBackgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar with new theme & ROUNDED edges (Adapted from buildAppBar)
              _buildThemedAppBar(context, title), // Pass dynamic title

              // Workout list container - WITH TOP ROUNDED corners (New UI Logic)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: darkBackgroundEnd.withOpacity(0.7), // Adjusted opacity
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        // Optionally add a subtle border on top if needed
                        // border: Border(top: BorderSide(color: highlightBlue.withOpacity(0.3), width: 1.0)),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 20, left: 0, right: 0), // Adjusted padding
                        itemCount: options.length, // Use actual options length
                        itemBuilder: (context, index) {
                          final option = options[index]; // Get the current ActivityOption
                          // Pass data to WorkoutTile and handle navigation
                          return WorkoutTile(
                            icon: option.icon, // Use icon from ActivityOption
                            title: option.name, // Use name from ActivityOption
                            highlight: highlightColors[index % highlightColors.length], // Cycle colors
                            onTileTap: () { // Define the tap action here
                              SoundManager.playClickSound(); // Original Logic
                              print("Selected: ${option.name} (Type: ${activityType.name})"); // Original Logic
                              Navigator.pushReplacement( // Original Logic
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActivityTimerScreen(
                                    activityType: activityType, // Pass the MAIN type
                                    duration: duration, // Pass the original duration
                                    specificActivityName: option.name, // Pass the SELECTED name
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Paste this below the ActivitySelectionScreen class

class WorkoutTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color highlight;
  final VoidCallback onTileTap; // <<< ADD THIS CALLBACK

  const WorkoutTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.highlight,
    required this.onTileTap, // <<< ADD THIS PARAMETER
  }) : super(key: key);

  @override
  State<WorkoutTile> createState() => _WorkoutTileState();
}

class _WorkoutTileState extends State<WorkoutTile> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final double currentBlurRadius = _isTapped ? 20 : 12;
    final double currentSpreadRadius = _isTapped ? 4 : 2;
    final double currentBorderOpacity = _isTapped ? 0.9 : 0.7;
    final double currentShadowOpacity = _isTapped ? 0.8 : 0.5;
    final Color tileBackgroundColor = _isTapped
        ? widget.highlight.withOpacity(0.20)
        : darkBackgroundEnd.withOpacity(0.8); // Use darkBackgroundEnd

    const double tileBorderRadius = 16.0;
    const double iconBorderRadius = 12.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapCancel: () => setState(() => _isTapped = false),
      onTapUp: (_) {
         setState(() => _isTapped = false);
         // Trigger the callback slightly after the animation settles
         Future.delayed(const Duration(milliseconds: 50), () {
             widget.onTileTap(); // <<< CALL THE PASSED CALLBACK HERE
         });
      },
      // We now handle the tap in onTapUp

      child: AnimatedContainer(
         duration: const Duration(milliseconds: 150),
         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
         decoration: BoxDecoration( // <<< Keep this decoration block
           color: tileBackgroundColor,
           borderRadius: BorderRadius.circular(tileBorderRadius),
           border: Border.all(
             color: widget.highlight.withOpacity(currentBorderOpacity),
             width: 1.5,
           ),
           boxShadow: [
             BoxShadow(
               color: widget.highlight.withOpacity(currentShadowOpacity),
               blurRadius: currentBlurRadius,
               spreadRadius: currentSpreadRadius,
             ),
             BoxShadow(
               color: Colors.black.withOpacity(0.5),
               blurRadius: 5,
               spreadRadius: 1,
               offset: const Offset(0, 2),
             ),
           ],
         ),
         child: Row( // <<< Keep the Row structure
            children: [
              // Icon Container
              Container( // <<< Keep Icon Container decoration
                 width: 45,
                 height: 45,
                 decoration: BoxDecoration(
                   color: widget.highlight.withOpacity(0.10),
                   borderRadius: BorderRadius.circular(iconBorderRadius),
                   border: Border.all(
                     color: widget.highlight.withOpacity(0.6),
                     width: 1,
                   ),
                   boxShadow: [
                     BoxShadow(
                       color: widget.highlight.withOpacity(0.5),
                       blurRadius: 10,
                       spreadRadius: 2,
                     ),
                   ],
                 ),
                 child: Center(
                   child: Icon(
                     widget.icon,
                     color: textWhite,
                     size: 24,
                   ),
                 ),
               ),
               const SizedBox(width: 20),
               // Title Text
               Expanded( // <<< Keep Title Text structure
                 child: Text(
                   widget.title,
                   style: TextStyle(
                     color: textWhite,
                     fontSize: 18,
                     fontWeight: FontWeight.w600,
                     letterSpacing: 1.2, // Optional: Adjust spacing if needed
                     fontFamily: 'DEM-MOMono', // Ensure font exists or remove
                     shadows: [
                       Shadow(
                         color: widget.highlight.withOpacity(0.9),
                         blurRadius: 12,
                       ),
                     ],
                   ),
                    overflow: TextOverflow.ellipsis,
                 ),
               ),
               // Chevron Icon
               Icon( // <<< Keep Chevron Icon
                 Icons.chevron_right,
                 color: widget.highlight,
                 size: 26,
                 shadows: [
                   Shadow(
                     color: widget.highlight.withOpacity(0.8),
                     blurRadius: 8,
                   ),
                 ]
               ),
             ],
         ),
      ),
    );
  }
}