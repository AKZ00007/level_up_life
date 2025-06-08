// lib/utils/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/services.dart'; // For rootBundle asset check
import 'dart:async'; // For StreamSubscription

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  // Sound Paths
  static const String _clickSoundPath = 'audio/click_sound.mp3';
  static const String _levelUpSoundPath = 'audio/levelUp.mp3';
  static const String _successSoundPath = 'audio/success.mp3';

  // Playback Flags
  static bool _isPlayingClick = false; // Separate flag for click sound
  static bool _isPlayingLevelUp = false; // Separate flag for level up sound
  static bool _isPlayingSuccess = false; // Separate flag for success sound

  // Initialize
  static Future<void> init() async {
    if (_isInitialized) return;

    // Configure the player - Optional: set release mode, etc.
    // await _player.setReleaseMode(ReleaseMode.stop); // Example configuration

    // Listen to player events (errors, state changes)
    _player.eventStream.listen((event) {
      // Handle events like completion, duration change if needed elsewhere
      // Note: onPlayerComplete is handled specifically in play methods now
    }, onError: (Object e, StackTrace stackTrace) {
      // Centralized error logging for the player instance
      if (kDebugMode) {
        print('!!! AudioPlayer Global Error: $e');
        print('!!! StackTrace: $stackTrace');
      }
    });

    // Pre-check asset availability during initialization (optional but helpful)
    await _checkAssetExists(_clickSoundPath);
    await _checkAssetExists(_levelUpSoundPath);
    await _checkAssetExists(_successSoundPath);

    _isInitialized = true;
    if (kDebugMode) print("SoundManager Initialized.");
  }

  // Helper to check if asset exists (avoids runtime errors during play)
  static Future<void> _checkAssetExists(String assetPath) async {
     try {
      await rootBundle.load('assets/$assetPath');
      if (kDebugMode) print("SoundManager: Asset '$assetPath' found during init check.");
    } catch (e) {
      if (kDebugMode) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        print("!!! SoundManager FATAL: Asset '$assetPath' NOT FOUND during init check.");
        print("!!! CHECK: file exists at 'assets/$assetPath'");
        print("!!! CHECK: 'assets/audio/' is declared in pubspec.yaml");
        print("!!! CHECK: Ran 'flutter pub get' after editing pubspec.yaml");
        print("!!! CHECK: Filename and path CASE SENSITIVITY");
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      }
      // Decide if this should prevent initialization or just warn
    }
  }


  // Play click sound (Using the generic helper)
  static Future<void> playClickSound() async {
    await _playSound(
      soundPath: _clickSoundPath,
      isPlayingFlag: _isPlayingClick,
      setPlayingFlag: (value) => _isPlayingClick = value,
      soundName: "Click",
      volume: 1.0,
      // Use mediaPlayer mode for more reliable completion events
      mode: PlayerMode.mediaPlayer,
      // Short fallback for clicks if completion event fails
      fallbackDuration: const Duration(milliseconds: 500),
    );
  }

  // Play level-up sound
  static Future<void> playLevelUpSound() async {
    await _playSound(
      soundPath: _levelUpSoundPath,
      isPlayingFlag: _isPlayingLevelUp,
      setPlayingFlag: (value) => _isPlayingLevelUp = value,
      soundName: "Level Up",
      volume: 1.0,
      fallbackDuration: const Duration(seconds: 5), // Estimate sound duration
    );
  }

  // Play success sound
  static Future<void> playSuccessSound() async {
    await _playSound(
      soundPath: _successSoundPath,
      isPlayingFlag: _isPlayingSuccess,
      setPlayingFlag: (value) => _isPlayingSuccess = value,
      soundName: "Success",
      volume: 0.8, // Use specified volume
      fallbackDuration: const Duration(seconds: 3), // Estimate sound duration
    );
  }


  // --- Generic Play Sound Helper ---
  static Future<void> _playSound({
      required String soundPath,
      required bool isPlayingFlag,
      required Function(bool) setPlayingFlag,
      required String soundName,
      double volume = 1.0,
      Duration? fallbackDuration, // Used if onPlayerComplete fails
      PlayerMode mode = PlayerMode.mediaPlayer, // Default for longer sounds
  }) async {
    // Add specific log for success sound entry
    // **** ADDED Logging ****
    if (soundName == "Success" && kDebugMode) print(">>> _playSound entered for Success sound.");

    if (kDebugMode) print("SoundManager: _playSound() called for '$soundName'.");
     if (!_isInitialized) {
       if (kDebugMode) print("SoundManager: Not initialized, skipping play '$soundName'.");
       return;
    }
    if (isPlayingFlag) {
      // **** MODIFIED Logging ****
      if (kDebugMode) print("SoundManager: '$soundName' already playing (flag is true), skipping rapid overlap.");
      return;
    }
    // **** ADDED Logging ****
    if (kDebugMode) print("SoundManager: Setting '$soundName' playing flag to true.");
    setPlayingFlag(true);

    StreamSubscription? subscription; // Declare here to be accessible in finally

    try {
      // **** MODIFIED Logging ****
      if (kDebugMode) print("SoundManager: Attempting to play AssetSource('$soundPath') for '$soundName'.");
      await _player.play(
        AssetSource(soundPath),
        volume: volume,
        mode: mode,
      );
      // **** MODIFIED Logging ****
      if (kDebugMode) print("SoundManager: Play command issued successfully for '$soundName'.");

      // Listen for sound completion to reset the flag
      subscription = _player.onPlayerComplete.listen((event) {
         // Add specific log for success sound completion
         // **** ADDED Logging ****
         if (soundName == "Success" && kDebugMode) print(">>> Success sound completed via event.");
         // **** MODIFIED Logging ****
         if (kDebugMode) print("SoundManager: '$soundName' sound completed via event. Resetting flag.");
         setPlayingFlag(false);
         subscription?.cancel(); // Clean up listener
      });

      // Fallback timer: Reset flag if completion event doesn't fire within expected time
      if (fallbackDuration != null) {
         Future.delayed(fallbackDuration, () {
           // Check the flag again! It might have been set to false by the event listener already.
           // **** MODIFIED Logic ****
           if (isPlayingFlag) {
             // Add specific log for success sound fallback
             // **** ADDED Logging ****
             if (soundName == "Success" && kDebugMode) print(">>> Success sound flag reset via fallback timer.");
             // **** MODIFIED Logging ****
             if (kDebugMode) print("SoundManager: '$soundName' flag reset via timer fallback. Completion event likely missed.");
             setPlayingFlag(false);
             subscription?.cancel(); // Clean up listener if timer expires first
           } else {
              // **** ADDED Logging ****
              if (kDebugMode) print("SoundManager: '$soundName' fallback timer fired, but flag was already false (event likely succeeded).");
              // No need to cancel subscription here as it should have already cancelled itself.
           }
         });
      }

    } on PlatformException catch (e) {
      // **** ADDED Logging ****
      if (soundName == "Success" && kDebugMode) print(">>> PlatformException during Success sound play.");
      _handlePlayError(soundName.toUpperCase(), e.message, e.code, e.details, null);
      setPlayingFlag(false);
      subscription?.cancel(); // Ensure listener is cancelled on error
    } catch (e, stackTrace) {
      // **** ADDED Logging ****
      if (soundName == "Success" && kDebugMode) print(">>> Generic Exception during Success sound play.");
      _handlePlayError(soundName.toUpperCase(), e.toString(), null, null, stackTrace);
      setPlayingFlag(false);
      subscription?.cancel(); // Ensure listener is cancelled on error
    }
    // Note: No finally block needed as flag reset happens in handlers/listeners
  }
  // --- End Generic Play Sound Helper ---

  // --- Centralized Error Handler ---
  static void _handlePlayError(String soundType, String? message, String? code, dynamic details, StackTrace? stackTrace) {
     if (kDebugMode) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        print("!!! SoundManager Error during $soundType play:");
        if (message != null) print("!!! Message: $message");
        if (code != null) print("!!! Code: $code");
        if (details != null) print("!!! Details: $details");
        if (stackTrace != null) print("!!! StackTrace: $stackTrace");
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      }
  }
  // --- End Error Handler ---


  // Dispose
  static void dispose() {
    _player.dispose();
    _isInitialized = false;
    // Reset flags on dispose might be good practice
    _isPlayingClick = false;
    _isPlayingLevelUp = false;
    _isPlayingSuccess = false;
    if (kDebugMode) print("SoundManager Disposed.");
  }
}