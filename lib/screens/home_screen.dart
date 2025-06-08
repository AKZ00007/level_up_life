// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // Import video_player
import '../providers/user_data_provider.dart';
import '../models/user_data.dart';
import 'activity_selection_screen.dart';
import 'health_screen.dart';
import '../utils/sound_manager.dart'; // <-- ADDED for sound effect

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    print("HomeScreen initState: Initializing video controller...");
    _controller = VideoPlayerController.asset(
      'assets/videos/background.mp4',
    )
      ..initialize().then((_) {
        if (!mounted) return;
        _controller?.play();
        _controller?.setLooping(true);
        _controller?.setVolume(0.0);
        print("HomeScreen initState: Video controller initialized and playing.");
        setState(() {});
      }).catchError((error) {
        print("Error initializing video player: $error");
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    print("HomeScreen dispose: Disposing video controller.");
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        if (userDataProvider.isLoading && userDataProvider.userData == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent))),
          );
        }
        if (userDataProvider.errorMessage != null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${userDataProvider.errorMessage}',
                  style: const TextStyle(color: Colors.redAccent, fontFamily: 'DEM-MOMono'), // <-- FONT ADDED
                ),
              ),
            ),
          );
        }
        if (userDataProvider.userData == null && !userDataProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text(
                'User data not available.',
                 style: TextStyle(color: Colors.white70, fontFamily: 'DEM-MOMono') // <-- FONT ADDED
                 )
             ),
          );
        }

        final userData = userDataProvider.userData!;
        final String playerName = "Adventurer"; // TODO: Make dynamic later
        final int playerLevel = userData.level;
        final int currentXP = userData.currentXp;
        final int nextLevelXP = userData.xpForNextLevel();
        final double progressValue = (nextLevelXP > 0)
            ? (currentXP.toDouble() / nextLevelXP.toDouble()).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          backgroundColor: Colors.black,

          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Video Background
              if (_controller != null && _controller!.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: Opacity(
                      opacity: 0.3, // Keep opacity low for visibility
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              else
                Container(color: Colors.black), // Fallback background

              // Main Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Player Info Card
                      _buildPlayerInfoCard(
                        playerName: playerName,
                        playerLevel: playerLevel,
                        progressValue: progressValue,
                        currentXP: currentXP,
                        maxXP: nextLevelXP,
                      ),
                      const SizedBox(height: 24),

                      // Grid View for Stat Cards
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0, // Adjust aspect ratio if needed
                          children: [
                            StatCard(
                              letter: 'S',
                              title: 'Strength',
                              displayValue: "Train",
                              color: Colors.blue.shade300, // Adjusted color
                              onTap: () {
                                // Navigate to Strength activity selection
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivitySelectionScreen(
                                      activityType: ActivityType.strength,
                                      // Example duration, pass relevant value
                                      duration: const Duration(seconds: 5),
                                    ),
                                  ),
                                );
                              },
                            ),
                            StatCard(
                              letter: 'I',
                              title: 'Intelligence',
                              displayValue: "Buff",
                               color: Colors.blue.shade300,  // Adjusted color
                              onTap: () {
                                // Navigate to Intelligence activity selection
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivitySelectionScreen(
                                      activityType: ActivityType.intelligence,
                                      // Example duration
                                      duration: const Duration(hours: 1),
                                    ),
                                  ),
                                );
                              },
                            ),
                            StatCard(
                              letter: 'H',
                              title: 'Health',
                              displayValue: "Log",
                              color: Colors.blue.shade300, // Adjusted color
                              onTap: () {
                                // Navigate to Health screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HealthScreen()),
                                );
                              },
                            ),
                            StatCard(
                              letter: 'C',
                              title: 'Consistency',
                              displayValue: '${userData.streakCount} Days',
                              color: Colors.blue.shade300,  // Adjusted color
                              onTap: () {
                                // Show streak info
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Current Streak: ${userData.streakCount} days!',
                                        style: const TextStyle(color: Colors.black, fontFamily: 'DEM-MOMono') // <-- FONT ADDED
                                    ),
                                    backgroundColor: Colors.blueAccent.shade100,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfoCard({
    required String playerName,
    required int playerLevel,
    required double progressValue,
    required int currentXP,
    required int maxXP,
  }) {
    // Height constant for the new progress bar
    const double progressBarHeight = 16.0; // Slightly reduced height maybe?

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7), // Slightly more opaque background
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5), // Adjusted glow
            blurRadius: 14,
            spreadRadius: 2,
          ),
           BoxShadow( // Subtle inner shadow for depth
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playerName.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.1,
              fontFamily: 'DEM-MOMono', // <-- FONT ADDED
              shadows: [ // Optional: subtle text shadow
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(1,1),
                )
              ]
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LEVEL $playerLevel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.lightBlue[100],
              fontFamily: 'DEM-MOMono', // <-- FONT ADDED
              shadows: [ // Optional: subtle text shadow
                 Shadow(
                  color: Colors.blueAccent.withOpacity(0.6),
                  blurRadius: 8,
                )
              ]
            ),
          ),
          const SizedBox(height: 12),

          // --- Use LayoutBuilder to get width for the SharpEdgeProgressBar ---
          LayoutBuilder(
            builder: (context, constraints) {
              // --- REPLACE THE OLD STACK WITH THE NEW WIDGET INSTANCE ---
              return SharpEdgeProgressBar(
                value: progressValue,                   // Pass the progress value
                width: constraints.maxWidth,            // Use available width
                height: progressBarHeight,              // Use defined height
                backgroundColor: Colors.grey[850]!.withOpacity(0.5), // Darker background
                valueColor: Colors.blueAccent.shade100, // Progress bar color
                showGlowingDot: true,                   // Enable the glowing dot
              );
              // --- END OF NEW WIDGET INSTANCE ---
            },
          ),
          // --- End of LayoutBuilder ---

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$currentXP / $maxXP XP',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
                fontFamily: 'DEM-MOMono', // <-- FONT ADDED
              ),
            ),
          ),
        ],
      ),
    );
  }
} // End of _HomeScreenState class

// --- PASTE THE NEW PROGRESS BAR WIDGET CODE HERE ---
// import 'package:flutter/material.dart'; // Already imported at the top

class SharpEdgeProgressBar extends StatelessWidget {
  final double value; // From 0.0 to 1.0
  final double height;
  final double width;
  final Color backgroundColor;
  final Color valueColor;
  final bool showGlowingDot;

  const SharpEdgeProgressBar({
    super.key,
    required this.value,
    this.height = 20,
    this.width = 300, // Default width, often overridden by LayoutBuilder
    required this.backgroundColor,
    required this.valueColor,
    this.showGlowingDot = true,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp value to prevent visual errors if it goes slightly out of bounds
    final clampedValue = value.clamp(0.0, 1.0);

    return SizedBox( // Use SizedBox to explicitly set dimensions
      width: width,
      height: height,
      child: Stack(
        children: [
          // Background
          Container(
            width: width,
            height: height,
            color: backgroundColor,
            // Optional: Add slight rounding if desired, but name implies sharp edges
            // borderRadius: BorderRadius.circular(2),
          ),
          // Progress Fill
          Container(
            width: width * clampedValue, // Use clamped value for accurate fill
            height: height,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(2), // Match background rounding if used
              color: valueColor, // Base color for solid fill
              gradient: LinearGradient( // Add subtle gradient for depth
                colors: [
                  valueColor.withOpacity(0.7), // Start slightly darker/transparent
                  valueColor,                 // Main color
                  Colors.white.withOpacity(0.8), // Highlight towards the top/middle
                  valueColor,                 // Back to main color
                ],
                stops: const [0.0, 0.4, 0.7, 1.0], // Adjust stops for highlight position
                begin: Alignment.centerLeft,
                end: Alignment.centerRight, // Or vertical gradient if preferred
              ),
              boxShadow: [ // Add glow effect to the progress fill
                BoxShadow(
                  color: valueColor.withOpacity(0.6), // Glow color based on valueColor
                  blurRadius: 8,  // Adjust blur intensity
                  spreadRadius: 0.5, // Adjust spread of the glow
                ),
              ],
            ),
          ),
          // Optional Glowing Dot at the end of the progress
          if (showGlowingDot && clampedValue > 0.01) // Only show if progress > 1%
            Positioned(
              // Calculate left position to center the dot AT THE END of the progress fill
              // (width * clampedValue) = end of the fill
              // (height / 2) = radius of the dot (since its width/height is 'height')
              left: (width * clampedValue) - (height / 2).clamp(0.0, width - height), // Clamp to stay within bounds
              // Align vertically in the center
              top: 0,
              bottom: 0,
              child: Container(
                width: height, // Dot diameter matches bar height for a rounded end feel
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Bright center for the dot
                  boxShadow: [
                    // Outer glow matching the progress bar color
                    BoxShadow(
                      color: valueColor.withOpacity(0.8), // Slightly stronger glow for dot
                      blurRadius: 12, // Larger blur for prominence
                      spreadRadius: 3,  // Larger spread
                    ),
                     // Inner white glow for brightness emphasis
                     BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
// --- END OF PASTED CODE ---


// --- Stat Card Widget (with tap sound and font) ---
class StatCard extends StatelessWidget {
  final String letter;
  final String title;
  final String displayValue;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.letter,
    required this.title,
    required this.displayValue,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SoundManager.playClickSound(); // Play sound first
        if (onTap != null) {
          onTap!(); // Execute the passed callback
        }
      },
      borderRadius: BorderRadius.circular(12.0), // Match container radius for ripple effect
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7), // Consistent background opacity
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color.withOpacity(0.8), width: 1.5),
          boxShadow: [
            // Outer, softer glow
            BoxShadow(
              color: color.withOpacity(0.6), // Main glow color
              blurRadius: 15, // Softer blur
              spreadRadius: 3,  // Wider spread
            ),
            // Inner, tighter highlight glow (optional, adds definition)
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 5,
              spreadRadius: 1,
            ),
             // Optional: Very subtle black shadow for depth against the background
             BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(1, 1), // Slight offset down and right
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large Letter
            Text(
              letter,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'DEM-MOMono', // <-- FONT ADDED
                shadows: [
                  Shadow(blurRadius: 6, color: color.withOpacity(0.7)) // Enhanced shadow
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Title Text
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.85),
                fontFamily: 'DEM-MOMono', // <-- FONT ADDED
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Display Value Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Slightly more padding
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4), // Slightly darker chip bg
                borderRadius: BorderRadius.circular(6),
                 border: Border.all( // Optional: Subtle border for the chip
                   color: color.withOpacity(0.3),
                   width: 1,
                 )
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'DEM-MOMono', // <-- FONT ADDED
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}