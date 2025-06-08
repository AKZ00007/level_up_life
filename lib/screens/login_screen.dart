// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // <-- ADDED
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../utils/sound_manager.dart'; // <-- ADDED: Import Sound Manager

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Initialize video
    print("LoginScreen initState: Initializing video controller...");
    _videoController = VideoPlayerController.asset(
      'assets/videos/background_loop.mp4',
    )
      ..initialize().then((_) {
        if (!mounted) return;
        _videoController?.play();
        _videoController?.setLooping(true);
        _videoController?.setVolume(0.0);
        print("LoginScreen initState: Video controller initialized and playing.");
        setState(() {});
      }).catchError((error) {
        print("Error initializing video player for LoginScreen: $error");
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    _videoController?.dispose();
    print("LoginScreen dispose: Disposing controllers.");
    super.dispose();
  }

  void _submitAuthForm() {
    SoundManager.playClickSound(); // <-- ADDED Sound Call
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@') || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password (min 6 chars).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_isLogin) {
      authProvider.signIn(email, password);
    } else {
      authProvider.signUp(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up')
            .animate()
            .fade(duration: 800.ms)
            .slideY(begin: -0.5, end: 0),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: Opacity(
                  opacity: 0.2,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            Container(color: const Color(0xFF0F172A)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Welcome Back' : 'Ready to be Player?',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.5))]),
                    ).animate().fade(delay: 200.ms).slideY(begin: -0.2),
                    const SizedBox(height: 25),

                    _buildTextField(_emailController, 'Email', TextInputType.emailAddress)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideX(begin: -0.5, end: 0),
                    const SizedBox(height: 15),
                    _buildTextField(_passwordController, 'Password', null, obscureText: true)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: 0.5, end: 0),
                    const SizedBox(height: 15),

                    if (authProvider.errorMessage != null && !authProvider.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                          textAlign: TextAlign.center,
                        ).animate().shakeX(),
                      ),

                    if (authProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: _buildElevatedButton(),
                      ),

                    const SizedBox(height: 15),
                    _buildToggleButton().animate().fade(delay: 500.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType? keyboardType, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purpleAccent.withOpacity(0.5), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: Colors.purpleAccent,
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: _submitAuthForm, // <-- Sound already called inside _submitAuthForm
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: Text(
        _isLogin ? 'Login' : 'Sign Up',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .shimmer(delay: 1.seconds, duration: 1.5.seconds, color: Colors.purpleAccent.withOpacity(0.3))
    .animate()
    .scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: () {
        SoundManager.playClickSound(); // <-- ADDED Sound Call
        Provider.of<AuthProvider>(context, listen: false).clearError();
        setState(() {
          _isLogin = !_isLogin;
          _emailController.clear();
          _passwordController.clear();
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        _isLogin ? 'Need an account? Sign Up' : 'Have an account? Login',
        style: TextStyle(
          color: Colors.blueAccent[100],
          fontSize: 15,
        ),
      ),
    );
  }
}
