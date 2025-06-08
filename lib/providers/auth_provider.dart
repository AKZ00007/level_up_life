// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      print("Auth State Changed: User is ${user?.uid}");
      _isLoading = false; // Stop loading once state is determined
      notifyListeners();
    });
  }

  // Clear any existing error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners(); // Notify UI to remove the error message
    }
  }

  // Set an error message and notify listeners
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Update the loading state only if it changes
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Sign Up method
  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    clearError(); // Clear previous errors on new attempt
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Successful sign-up; listener will update _user and loading state.
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? "Sign up failed.");
      _setLoading(false); // Stop loading on error
    } catch (e) {
      _setError("An unexpected error occurred.");
      _setLoading(false); // Stop loading on error
    }
  }

  // Sign In method
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    clearError(); // Clear previous errors on new attempt
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Successful sign-in; listener will update _user and loading state.
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? "Sign in failed.");
      _setLoading(false);
    } catch (e) {
      _setError("An unexpected error occurred.");
      _setLoading(false);
    }
  }

  // Sign Out method
  Future<void> signOut() async {
    _setLoading(true); // Optional: show loading during sign out
    await _auth.signOut();
    // Listener will update _user to null automatically
  }
}
