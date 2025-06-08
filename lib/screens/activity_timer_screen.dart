// lib/screens/activity_timer_screen.dart

import 'dart:async';
import 'dart:math' as math; // For painter calculations
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // Import video player

import '../providers/user_data_provider.dart';
import '../models/user_data.dart';
import '../utils/sound_manager.dart'; // <-- IMPORT SOUND MANAGER

// --- Define App Colors for easy theming ---
class AppColors {
  static const Color background = Color(0xFF000510); // Very dark blue/black
  static const Color primaryBlue = Color(0xFF00AFFF); // Bright Neon Blue
  static const Color lightBlue = Color(0xFF80DFFF); // Lighter Blue for accents
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0C4DE); // Lighter blue-grey text
  static const Color buttonGreen = Color(0xFF00FF87); // Neon Green like image
  static const Color buttonRed = Color(0xFFFF4D4D); // Neon Red for cancel/reset
}
// --- End App Colors ---

class ActivityTimerScreen extends StatefulWidget {
  final ActivityType activityType; // e.g., Strength or Intelligence
  final Duration duration;
  final String specificActivityName; // e.g., "Warrior's Workout"

  const ActivityTimerScreen({
    super.key,
    required this.activityType,
    required this.duration,
    required this.specificActivityName,
  });

  @override
  State<ActivityTimerScreen> createState() => _ActivityTimerScreenState();
}

class _ActivityTimerScreenState extends State<ActivityTimerScreen> with WidgetsBindingObserver {
  Timer? _timer;
  late Duration _remainingTime;
  bool _isTimerRunning = false; // Tracks if timer is ticking
  bool _isTimerPausedManually = false; // Tracks user pause action
  bool _isCompleted = false;
  bool _pausedDueToBackground = false; // Tracks if pause was due to app lifecycle

  VideoPlayerController? _videoController;
  bool _isVideoControllerInitialized = false;

  // Consistent font family
  static const String appFontFamily = 'DEM-MOMono';

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayer(); // Initialize video
    print("Timer screen init. Remaining: $_remainingTime");
  }

  // Initialize Video Player with Logging and Error Handling
  Future<void> _initializeVideoPlayer() async {
    print("Attempting to initialize VideoPlayer for timer.mp4");
    _videoController = VideoPlayerController.asset('assets/videos/timer.mp4');
    try {
      await _videoController!.initialize();
      print("VideoController Initialized");
      await _videoController!.setLooping(true);
      print("VideoController Looping Set");
      await _videoController!.setVolume(0.0);
      print("VideoController Volume Set");

      // Crucial: Add listener for errors *after* initialization
      _videoController!.addListener(() {
          // Check if the controller is still valid and has a value
          if (_videoController != null && _videoController!.value.hasError) {
              print("!!! Video Player Runtime Error: ${_videoController!.value.errorDescription}");
              // Optionally update UI or state to indicate video error
          }
      });

      if (mounted) {
        setState(() {
          _isVideoControllerInitialized = true;
        });
        print("Video player initialization successful and state set.");
      } else {
        print("Video player initialized BUT component not mounted anymore.");
        _videoController?.dispose(); // Dispose if not mounted
      }
    } catch (e, stackTrace) {
      print("!!! CATCH BLOCK: Error initializing video player: $e");
      print(stackTrace);
      if(mounted) {
          // Mark as not initialized on error
          setState(() {
             _isVideoControllerInitialized = false;
          });
          // Optionally show error to user via Snackbar or Dialog
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
                content: Text(
                    'Error loading background video.',
                     style: TextStyle(fontFamily: appFontFamily, color: AppColors.textPrimary)
                 ),
                 backgroundColor: Colors.redAccent
             )
          );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // Check if controller exists before removing listener
    if (_videoController != null) {
       try {
         // Using a no-op listener for removal as recommended by Flutter docs
         // if the original listener function isn't stored.
         _videoController!.removeListener(() {});
       } catch (e) {
          print("Error removing video listener during dispose: $e");
       }
    }
    _videoController?.dispose();
    print("Timer screen disposed.");
    super.dispose();
  }

  // App Lifecycle Handling with Logging and Error Handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("App Lifecycle State Changed: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        if (_pausedDueToBackground) {
          _pausedDueToBackground = false;
          // Resume only if timer should be running (wasn't manually paused)
          if (_isTimerRunning && !_isTimerPausedManually) {
            print("Resuming timer and video from background pause.");
            _startTimerLogic(); // Restart timer ticks
            try {
               if (_isVideoControllerInitialized) _videoController?.play(); // Resume video
            } catch (e,s) { print("!!! Error resuming video play: $e\n$s"); }
          } else {
            print("App resumed, but timer was manually paused or not running. Video remains paused (if manually paused).");
            // Ensure video state matches manual pause state if necessary
             if(_isTimerPausedManually && _isVideoControllerInitialized) {
                 try { _videoController?.pause(); } catch(e,s){print("!!! Error ensuring video pause on resume: $e\n$s");}
             }
          }
        } else {
            print("App resumed, but wasn't paused due to background.");
            // Ensure video state reflects current timer state correctly
             if(_isTimerPausedManually && _isVideoControllerInitialized) {
                 try { _videoController?.pause(); } catch(e,s){print("!!! Error ensuring video pause on resume (not backgrounded): $e\n$s");}
             } else if (_isTimerRunning && _isVideoControllerInitialized) {
                 try { _videoController?.play(); } catch(e,s){print("!!! Error ensuring video play on resume (not backgrounded): $e\n$s");}
             }
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Pause only if timer is running and wasn't manually paused
        if (_isTimerRunning && !_isTimerPausedManually) {
          print("Pausing timer and video due to background/inactive state.");
          _timer?.cancel(); // Stop timer ticks
          try {
            if (_isVideoControllerInitialized) _videoController?.pause(); // Pause video
          } catch (e,s) { print("!!! Error pausing video on background: $e\n$s"); }
          _pausedDueToBackground = true; // Mark reason for pause
        } else {
          print("App backgrounded, but timer wasn't running or was manually paused. No lifecycle pause needed.");
        }
        break;
      case AppLifecycleState.detached:
        print("App Detached: Stopping timer and video.");
        _timer?.cancel();
        try {
          if (_isVideoControllerInitialized) _videoController?.pause();
        } catch (e,s) { print("!!! Error pausing video on detach: $e\n$s"); }
        break;
    }
    if (mounted) {
      setState(() {}); // Refresh UI if necessary
    }
  }


  // Start/Resume Timer and Video Control
  void _startOrResumeTimer() {
    SoundManager.playClickSound();
    if (_isCompleted) return;

    // Ensure video is ready before trying to play
    if (!_isVideoControllerInitialized) {
       print("Video not ready, cannot start playback yet.");
       // Optionally show a message to the user
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Background loading...',
                  style: TextStyle(fontFamily: appFontFamily, color: AppColors.textSecondary)
              ),
              duration: Duration(seconds: 1)
          )
       );
       return;
    }

    // Only start timer logic if it's not already ticking
    if (!_isTimerRunning) {
       _startTimerLogic(); // Starts the Timer.periodic
    }

    // Always ensure video plays when this action is intended (start or resume)
    try {
       print("Attempting to PLAY video in _startOrResumeTimer");
       _videoController?.play(); // Explicitly play
    } catch (e, stackTrace) {
       print("!!! ERROR playing video in _startOrResumeTimer: $e");
       print(stackTrace);
    }

    // Update state AFTER initiating actions
    setState(() {
      _isTimerRunning = true; // Timer should be ticking now
      _isTimerPausedManually = false; // It's not manually paused
    });
    print("Timer State: Running. Remaining: $_remainingTime");
  }

  // Pause Timer and Video Control (User Action)
  void _pauseTimerByUser() {
     SoundManager.playClickSound();
     // Can only pause if timer is actively running (not already paused)
     if (_isTimerRunning && !_isTimerPausedManually) {
        _timer?.cancel(); // Stop the timer ticks

        try {
           print("Attempting to PAUSE video in _pauseTimerByUser");
           if (_isVideoControllerInitialized) _videoController?.pause(); // Pause video
        } catch (e, stackTrace) {
           print("!!! ERROR pausing video in _pauseTimerByUser: $e");
           print(stackTrace);
        }

        // Update state AFTER attempting pause
        setState(() {
           _isTimerRunning = false; // It's not ticking anymore
           _isTimerPausedManually = true; // Mark as manually paused
        });
        print("Timer State: Paused by user. Remaining: $_remainingTime");
     } else {
        print("Pause called but timer wasn't running or already paused.");
     }
  }

  // Core Timer Logic (separated)
  void _startTimerLogic() {
     _timer?.cancel(); // Ensure no duplicate timers
     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (!mounted) {
         timer.cancel();
         return;
       }
       if (_remainingTime.inSeconds > 0) {
          // Ensure we don't go below zero if called rapidly
          if (_remainingTime.inSeconds > 0) {
             setState(() {
               _remainingTime -= const Duration(seconds: 1);
             });
          }
       } else {
          // Timer reached zero
          timer.cancel(); // Stop this timer instance
          // Check _isCompleted flag again before calling _onTimerComplete to prevent potential double calls
          if (!_isCompleted) {
             _onTimerComplete(); // Handle completion logic
          }
       }
     });
  }


  // Cancel Timer and Video Control
  // **** MODIFIED according to instructions (Verification Step) ****
  void _cancelTimer({bool showMessage = true}) {
    print("Cancelling timer manually.");
    _timer?.cancel(); // Stop timer ticks

    try {
       print("Attempting to PAUSE video in _cancelTimer");
       if (_isVideoControllerInitialized) _videoController?.pause(); // Pause video on cancel
    } catch (e, stackTrace) {
       print("!!! ERROR pausing video in _cancelTimer: $e");
       print(stackTrace);
    }

    // Store if timer was active to decide on showing the message
    final bool wasActive = _isTimerRunning || _isTimerPausedManually;

    // Reset state variables to allow popping
    _isTimerRunning = false;
    _isTimerPausedManually = false;
    _pausedDueToBackground = false;

    if (mounted) {
       // Only show message if it was actually running/paused before cancelling
       if (showMessage && wasActive) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
               content: Text(
                   'Activity cancelled. No XP awarded.',
                    style: TextStyle(fontFamily: appFontFamily, color: AppColors.textPrimary)
               ),
               backgroundColor: AppColors.buttonRed, // Use new red
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
               behavior: SnackBarBehavior.floating,
               margin: EdgeInsets.all(10),
            ),
         );
       }
       // Update UI state *if needed* after resetting flags
       print("Calling setState in _cancelTimer"); // <-- Add log for confirmation
       setState(() {}); // <-- THIS IS ESSENTIAL and verified to be present
    } else {
      print("_cancelTimer called but not mounted");
    }
    // NO Navigator call here!
  }
  // **** END OF MODIFICATION ****


  // Timer Completion Logic
  void _onTimerComplete() {
    print("Timer Completed for ${widget.activityType.name} (${widget.specificActivityName})");

    // Ensure state flags reflect completion FIRST
    _isTimerRunning = false;
    _isTimerPausedManually = false;
    _isCompleted = true;

    try {
       print("Attempting to PAUSE video in _onTimerComplete");
       if (_isVideoControllerInitialized) _videoController?.pause();
    } catch (e, stackTrace) {
       print("!!! ERROR pausing video in _onTimerComplete: $e");
       print(stackTrace);
    }

    if (mounted) {
      // Update the UI FIRST to show completion visually
      setState(() {});

      // Introduce a small delay BEFORE playing sound
      Future.delayed(const Duration(milliseconds: 100), () { // Delay of 100ms
         if (mounted && _isCompleted) { // Re-check mounted and completion status
            print(">>> (After Delay) Attempting to play SUCCESS sound...");
            SoundManager.playSuccessSound(); // Play success sound
            print(">>> (After Delay) Call to play SUCCESS sound finished.");

            // Grant XP and Show SnackBar *after* initiating sound playback
            // Ensure context is still valid if needed by provider/snackbar logic
            if (mounted) {
               Provider.of<UserDataProvider>(context, listen: false)
                 .completeTimedActivity(widget.activityType);

               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text(
                     '${widget.specificActivityName} Complete! XP Awarded!',
                      style: const TextStyle(fontFamily: appFontFamily, color: Colors.black87)
                   ),
                   backgroundColor: AppColors.buttonGreen,
                   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                   behavior: SnackBarBehavior.floating,
                   margin: const EdgeInsets.all(10),
                   duration: const Duration(seconds: 3),
                 ),
               );
            }

         } else {
            print(">>> (After Delay) Not playing sound - unmounted or no longer completed.");
         }
      });
    } else {
      print("_onTimerComplete called but not mounted");
    }
  }


  // Format Duration for Display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    int totalSeconds = duration.inSeconds.clamp(0, 86400); // Max 24 hours

    String seconds = twoDigits(totalSeconds % 60);
    String minutes = twoDigits((totalSeconds ~/ 60) % 60);
    String hours = twoDigits(totalSeconds ~/ 3600);

    if (totalSeconds >= 3600) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  // Calculate Progress for Painter (0.0 to 1.0)
  double get _timerProgress {
    if (widget.duration.inSeconds <= 0) return 0.0;
    // Ensure remaining time doesn't go below zero for calculation
    final clampedRemaining = _remainingTime.inSeconds.clamp(0, widget.duration.inSeconds);
    return (clampedRemaining / widget.duration.inSeconds).clamp(0.0, 1.0);
  }


  // Build Custom AppBar
  Widget _buildCustomAppBar(BuildContext context) {
    void handleBackPress() {
      SoundManager.playClickSound();
      Navigator.maybePop(context); // Interacts with PopScope
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15, right: 15, bottom: 10,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: handleBackPress,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightBlue.withOpacity(0.5))
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              widget.specificActivityName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 20,
                  fontWeight: FontWeight.bold, fontFamily: appFontFamily,
                  letterSpacing: 1.2,
                  shadows: [ Shadow(color: AppColors.primaryBlue, blurRadius: 10)]
              ),
            ),
          ),
          const SizedBox(width: 40 + 15.0), // Balance back button space
        ],
      ),
    );
  }


  // Main Build Method
  @override
  Widget build(BuildContext context) {
    // Determine button state based on timer status
    bool canStart = !_isTimerRunning && !_isCompleted && !_isTimerPausedManually;
    bool canResume = _isTimerPausedManually && !_isCompleted;
    bool canPause = _isTimerRunning && !_isTimerPausedManually && !_isCompleted;

    String buttonText = 'Start Activity';
    IconData buttonIcon = Icons.play_arrow;
    VoidCallback? buttonAction = _startOrResumeTimer; // Default action

    if (canResume) {
       buttonText = 'Resume Activity';
       // Icon remains play_arrow for resume
    } else if (canPause) {
       buttonText = 'Pause Activity';
       buttonIcon = Icons.pause;
       buttonAction = _pauseTimerByUser; // Action is pause
    } else if (!canStart && !canResume && !canPause && !_isCompleted) {
       // If none of the above states match (e.g., initializing), disable button
       buttonAction = null;
    }
    // If completed, button is hidden anyway

    return PopScope(
      // **** PopScope canPop logic relies on these flags ****
      canPop: !_isTimerRunning && !_isTimerPausedManually, // Can pop freely ONLY if timer not active (running or paused)
      onPopInvoked: (didPop) {
        if (didPop) return; // Already popped by system or allowed by canPop

        // If canPop was false, show confirmation dialog
         showDialog(
          context: context, barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.background.withOpacity(0.95),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: AppColors.lightBlue.withOpacity(0.5))
             ),
            title: const Text('Cancel Activity?', style: TextStyle(color: AppColors.textPrimary, fontFamily: appFontFamily)),
            content: const Text('Leave now and you won\'t get XP. Are you sure?', style: TextStyle(color: AppColors.textSecondary, fontFamily: appFontFamily)),
            actions: [
              TextButton(
                child: const Text('No', style: TextStyle(color: Colors.grey, fontFamily: appFontFamily)),
                onPressed: () {
                   SoundManager.playClickSound();
                   Navigator.of(ctx).pop(false); // Close dialog, don't pop screen
                }
              ),
              // **** MODIFIED PopScope Dialog Button (with PostFrameCallback) ****
              TextButton(
                child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.buttonRed, fontFamily: appFontFamily, fontWeight: FontWeight.bold)),
                onPressed: () {
                  SoundManager.playClickSound();
                  // 1. Close the dialog first
                  Navigator.of(ctx).pop();
                  // 2. Clean up timer state (this calls setState internally)
                  _cancelTimer(showMessage: true); // Make sure _cancelTimer calls setState!

                  // 3. Schedule the actual screen pop for AFTER the current frame
                  //    This ensures the state update from _cancelTimer is processed
                  //    before maybePop checks the PopScope's canPop condition.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Double-check if the widget is still mounted before popping
                    if (mounted) {
                      print("Post-frame callback (PopScope): Attempting maybePop...");
                      Navigator.maybePop(context);
                    } else {
                       print("Post-frame callback (PopScope): Widget unmounted, not popping.");
                    }
                  });
                },
              ),
              // **** END OF MODIFICATION ****
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Video Background
            if (_isVideoControllerInitialized && _videoController != null && _videoController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: Opacity(
                    opacity: 0.25,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              Container(color: Colors.black), // Fallback

            // UI Layer
            Column(
              children: [
                _buildCustomAppBar(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular Timer Display
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
                            padding: const EdgeInsets.all(15.0),
                            child: CustomPaint(
                              painter: DottedCircleTimerPainter(
                                progress: _timerProgress,
                                glowColor: AppColors.primaryBlue,
                                dotColor: AppColors.lightBlue.withOpacity(0.3),
                                numberOfDots: 60,
                                dotRadius: 4.5,
                              ),
                              child: Center(
                                child: _isCompleted
                                    ? const Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.buttonGreen,
                                        size: 90,
                                        shadows: [Shadow(color: AppColors.buttonGreen, blurRadius: 20)],
                                      )
                                    : Text(
                                        _formatDuration(_remainingTime),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 65,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: appFontFamily,
                                          letterSpacing: 2.0,
                                          shadows: [
                                            Shadow(color: AppColors.primaryBlue, blurRadius: 25.0),
                                            Shadow(color: Colors.black54, blurRadius: 5.0, offset: Offset(1,1))
                                          ]
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Start/Pause/Resume Button
                        if (!_isCompleted)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: (canPause) ? AppColors.primaryBlue.withOpacity(0.8) : AppColors.buttonGreen,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: appFontFamily),
                                elevation: 8,
                                shadowColor: (canPause) ? AppColors.primaryBlue.withOpacity(0.5) : AppColors.buttonGreen.withOpacity(0.5)
                             ),
                             onPressed: buttonAction, // Use determined action, null disables
                             icon: Icon(
                               buttonIcon,
                               size: 30, color: Colors.black,
                             ),
                             label: Text(buttonText),
                           )
                        else
                           Padding( // Show completion text
                             padding: const EdgeInsets.only(top: 20.0),
                             child: const Text(
                                'Activity Complete!',
                                style: TextStyle(fontSize: 22, color: AppColors.buttonGreen, fontWeight: FontWeight.bold, fontFamily: appFontFamily)
                             ),
                           ),
                        const SizedBox(height: 25),

                        // Cancel Button (conditionally visible)
                        Opacity(
                           opacity: !_isCompleted ? 1.0 : 0.0, // Hide when completed
                           child: IgnorePointer(
                              ignoring: _isCompleted, // Prevent tap when hidden
                              child: TextButton(
                                onPressed: () {
                                   // Show cancel confirmation dialog
                                   showDialog(
                                    context: context, barrierDismissible: false,
                                    builder: (ctx) => AlertDialog(
                                       backgroundColor: AppColors.background.withOpacity(0.95),
                                       shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(15),
                                           side: BorderSide(color: AppColors.lightBlue.withOpacity(0.5))
                                        ),
                                       title: const Text('Cancel Activity?', style: TextStyle(color: AppColors.textPrimary, fontFamily: appFontFamily)),
                                       content: const Text('Leave now and you won\'t get XP. Are you sure?', style: TextStyle(color: AppColors.textSecondary, fontFamily: appFontFamily)),
                                       actions: [
                                         TextButton(
                                           child: const Text('No', style: TextStyle(color: Colors.grey, fontFamily: appFontFamily)),
                                           onPressed: () { SoundManager.playClickSound(); Navigator.of(ctx).pop(); }
                                         ),
                                         // **** MODIFIED Manual Cancel Dialog Button (with PostFrameCallback) ****
                                         TextButton(
                                           child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.buttonRed, fontFamily: appFontFamily, fontWeight: FontWeight.bold)),
                                           onPressed: () {
                                              SoundManager.playClickSound();
                                              // 1. Close the dialog first
                                              Navigator.of(ctx).pop();
                                              // 2. Clean up timer state (this calls setState internally)
                                              _cancelTimer(showMessage: true); // Make sure _cancelTimer calls setState!

                                              // 3. Schedule the actual screen pop for AFTER the current frame
                                              //    This ensures the state update from _cancelTimer is processed
                                              //    before maybePop checks the PopScope's canPop condition.
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                // Double-check if the widget is still mounted before popping
                                                if (mounted) {
                                                  print("Post-frame callback (Manual Cancel): Attempting maybePop...");
                                                  Navigator.maybePop(context);
                                                } else {
                                                   print("Post-frame callback (Manual Cancel): Widget unmounted, not popping.");
                                                }
                                              });
                                           },
                                         ),
                                         // **** END OF MODIFICATION ****
                                       ],
                                     ),
                                  );
                                },
                                child: const Text(
                                  'Cancel Activity',
                                  style: TextStyle(
                                    color: AppColors.buttonRed, fontSize: 16,
                                    fontFamily: appFontFamily,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.buttonRed,
                                  ),
                                ),
                              ),
                           ),
                         ),
                         const Spacer(), // Push content up
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} // End of _ActivityTimerScreenState


// --- Custom Painter for the Dotted Circular Timer ---
class DottedCircleTimerPainter extends CustomPainter {
  final double progress; // Remaining progress (0.0 to 1.0)
  final Color glowColor;
  final Color dotColor;
  final int numberOfDots;
  final double dotRadius;

  DottedCircleTimerPainter({
    required this.progress,
    required this.glowColor,
    required this.dotColor,
    this.numberOfDots = 60,
    this.dotRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY) - dotRadius * 3.5;
    final double angleStep = (2 * math.pi) / numberOfDots;
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    final clampedProgress = progress.clamp(0.0, 1.0);
    final int activeDotsCount = (clampedProgress * numberOfDots).ceil();

    for (int i = 0; i < numberOfDots; i++) {
      final double currentAngle = -math.pi / 2 + (i * angleStep);
      final double dotX = centerX + radius * math.cos(currentAngle);
      final double dotY = centerY + radius * math.sin(currentAngle);
      final Offset dotCenter = Offset(dotX, dotY);
      final bool isActive = i < activeDotsCount;

      if (isActive) {
        canvas.drawCircle(dotCenter, dotRadius * 2.0, glowPaint);
        canvas.drawCircle(dotCenter, dotRadius, dotPaint..color = glowColor);
      } else {
        canvas.drawCircle(dotCenter, dotRadius * 0.8, dotPaint..color = dotColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DottedCircleTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.numberOfDots != numberOfDots ||
        oldDelegate.dotRadius != dotRadius;
  }
}
// --- End Custom Painter ---