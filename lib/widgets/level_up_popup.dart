// lib/widgets/level_up_popup.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Ensure dart:math is imported
// Assuming you have a SoundManager class, otherwise remove/comment out the import and calls
// import 'package:your_app/utils/sound_manager.dart'; // Example path

// Popup notification widget
class LevelUpNotificationPopup extends StatelessWidget {
  final int newLevel;
  final String levelName;

  const LevelUpNotificationPopup({
    super.key,
    required this.newLevel,
    required this.levelName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack( // Parent Stack
        children: [ // Start of Stack Children List

          // Child 1: Background Effect
          const DigitalCircuitOverlay(),

          // Child 2: Main Content Area
          GlowingBorderContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Content INSIDE the Column ---
                    Row( // Notification header Row
                      children: [
                        const GlowingBorderContainer(
                          glowColor: Color(0xFF00CCFF),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: PulsingIcon(
                              icon: Icons.arrow_upward,
                              color: Color(0xFF00CCFF),
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlowingBorderContainer(
                            glowColor: const Color(0xFF00CCFF),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: GlitchText(
                                  text: 'LEVEL UP!',
                                  style: const TextStyle(
                                    color: Color(0xFF00CCFF),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const PulsingText( // Notification message
                      text: 'Congratulations Adventurer!\nYou have ascended!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const AnimatedChevrons(), // Animated chevrons
                    const SizedBox(height: 20),
                    GlowingBorderContainer( // Level display
                      glowColor: const Color(0xFF00CCFF),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'REACHED LEVEL $newLevel',
                                style: const TextStyle(
                                  color: Color(0xFF4CFF50),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              GlowingText(
                                text: levelName,
                                style: const TextStyle(
                                  color: Color(0xFF4CFF50),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                                glowColor: const Color(0xFF4CFF50),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlowingBorderContainer( // Continue button container
                      glowColor: const Color(0xFF00CCFF),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            print("Continue button tapped on level up popup.");
                            // SoundManager.playClickSound();
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            child: Text(
                              'CONTINUE',
                              style: TextStyle(
                                color: Color(0xFF00CCFF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ), // End of Continue button container
                    // --- End of Content INSIDE the Column ---
                  ], // End of Column children
                ), // End of SingleChildScrollView
              ), // End of Padding
            ), // End of child for GlowingBorderContainer
          ), // End of GlowingBorderContainer (Child 2)

          // **** Comma separating Child 2 and Child 3 ****

          // Child 3: Close Button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Close',
                onPressed: () {
                  print("Close button (X) tapped on level up popup.");
                  // SoundManager.playClickSound();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ), // End of Positioned (Child 3)

        ], // End of Stack Children List
      ), // End of Stack
    ); // End of Dialog
  }
}


// ===========================================
// SUPPORTING WIDGETS (Remain Unchanged)
// ===========================================

// Digital circuit overlay animation
class DigitalCircuitOverlay extends StatefulWidget {
  const DigitalCircuitOverlay({super.key});

  @override
  State<DigitalCircuitOverlay> createState() => _DigitalCircuitOverlayState();
}

class _DigitalCircuitOverlayState extends State<DigitalCircuitOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: CircuitPainter(_controller.value),
            child: Container(),
            isComplex: true,
            willChange: true,
          );
        },
      ),
    );
  }
}

class CircuitPainter extends CustomPainter {
  final double animValue;

  CircuitPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0066CC).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF00AAFF).withOpacity(0.2 + 0.1 * math.sin(animValue * math.pi * 2))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);

    final spacingHorizontal = size.width / 10;
    final spacingVertical = size.height / 15;

    for (var i = 1; i < 15; i++) {
      final y = i * spacingVertical;
      final opacity = 0.2 + 0.1 * math.sin((animValue * 2 + i / 15) * math.pi * 2);
      paint.color = const Color(0xFF0066CC).withOpacity(opacity);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 1; i < 10; i++) {
      final x = i * spacingHorizontal;
      final opacity = 0.2 + 0.1 * math.sin((animValue * 2 + i / 10) * math.pi * 2);
      paint.color = const Color(0xFF0066CC).withOpacity(opacity);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final dataPaint = Paint()
      ..color = const Color(0xFF00AAFF).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dataPos = (animValue * size.width * 2) % (size.width * 1.5) - size.width * 0.25;
    canvas.drawLine(Offset(dataPos, 0), Offset(dataPos + size.width * 0.25, size.height), dataPaint);

    final dataPos2 = (animValue * size.width + size.width / 2) % (size.width * 1.5) - size.width * 0.25;
    canvas.drawLine(Offset(dataPos2 + size.width * 0.25, 0), Offset(dataPos2, size.height), dataPaint);
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) => oldDelegate.animValue != animValue;
}

// Container with glowing border animation
class GlowingBorderContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final BorderRadius borderRadius;

  const GlowingBorderContainer({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00AAFF),
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<GlowingBorderContainer> createState() => _GlowingBorderContainerState();
}

class _GlowingBorderContainerState extends State<GlowingBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.glowColor.withOpacity(_animation.value * 0.7),
              width: 1.5,
            ),
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value * 0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
            color: Colors.black.withOpacity(0.75),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Pulsing icon animation
class PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const PulsingIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Icon(
          widget.icon, // Positional argument first
          color: widget.color, // Named argument
          size: widget.size * _animation.value, // Named argument
          shadows: [
            Shadow(
              color: widget.color.withOpacity(0.5 * (_animation.value - 0.8) / 0.4),
              blurRadius: 4.0 * _animation.value,
            ),
          ],
        );
      },
    );
  }
}

// Glowing text animation
class GlowingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;

  const GlowingText({
    super.key,
    required this.text,
    required this.style,
    required this.glowColor,
  });

  @override
  State<GlowingText> createState() => _GlowingTextState();
}

class _GlowingTextState extends State<GlowingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Text(
          widget.text,
          style: widget.style.copyWith(
            shadows: [
              Shadow(
                color: widget.glowColor.withOpacity(0.7),
                blurRadius: _animation.value,
              ),
               Shadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 1.0,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Pulsing text animation
class PulsingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const PulsingText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  State<PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) {
        return Opacity(
          opacity: 0.8 + (_animation.value * 0.2),
          child: Text(
            widget.text,
            textAlign: widget.textAlign,
            style: widget.style,
          ),
        );
      },
    );
  }
}

// Animated Chevrons
class AnimatedChevrons extends StatefulWidget {
  const AnimatedChevrons({super.key});

  @override
  State<AnimatedChevrons> createState() => _AnimatedChevronsState();
}

class _AnimatedChevronsState extends State<AnimatedChevrons>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        const double phaseShift = math.pi / 3;
        final double baseValue = _controller.value * math.pi * 2;

        final opacities = List.generate(3, (index) {
           double sineValue = math.sin(baseValue - (index * phaseShift));
           double mappedValue = (sineValue + 1) / 2;
           double easedValue = Curves.easeInOut.transform(mappedValue);
           return easedValue.clamp(0.0, 1.0);
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Icon(
              Icons.keyboard_arrow_down, // Positional first
              color: const Color(0xFF00CCFF).withOpacity(opacities[index]), // Named
              size: 30 + (opacities[index] * 5), // Named
               shadows: [ // Named
                Shadow(
                  color: const Color(0xFF00CCFF).withOpacity(opacities[index] * 0.5),
                  blurRadius: 4,
                )
               ]
            );
          }),
        );
      },
    );
  }
}

// Glitch effect for text
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const GlitchText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayText = '';
  bool _glitching = false;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_maybeGlitch);
  }

  void _maybeGlitch() {
    if (!_glitching && _random.nextDouble() < 0.015) {
      _startGlitch();
    }
  }

  void _startGlitch() {
    if (!mounted) return;
    _glitching = true;
    String glitchText = widget.text;
    if (widget.text.isNotEmpty) {
      final charToReplace = _random.nextInt(widget.text.length);
      const String charSet = "█▓▒░<>/\\|{}[]?*&^%\$#@!~1234567890";
      final replacement = charSet[_random.nextInt(charSet.length)];
      glitchText = glitchText.substring(0, charToReplace) + replacement + glitchText.substring(charToReplace + 1);
    }
    setState(() => _displayText = glitchText);

    Future.delayed(Duration(milliseconds: 40 + _random.nextInt(100)), () {
      if (mounted) {
        setState(() {
          _displayText = widget.text;
          _glitching = false;
        });
      } else {
         _glitching = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeGlitch);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return Text(
       _displayText,
       style: widget.style.copyWith(
         shadows: [
           Shadow(
             color: (widget.style.color ?? Colors.cyan).withOpacity(0.6),
             blurRadius: 8,
           ),
           if (_glitching)
             Shadow(
               color: Colors.redAccent.withOpacity(0.7),
               blurRadius: 4,
               offset: Offset(_random.nextDouble() * 4 - 2, _random.nextDouble() * 4 - 2),
             ),
           if (_glitching)
             Shadow(
               color: Colors.blueAccent.withOpacity(0.7),
               blurRadius: 4,
               offset: Offset(_random.nextDouble() * -4 + 2, _random.nextDouble() * -4 + 2),
             ),
         ],
       ),
     );
  }
}