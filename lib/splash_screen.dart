import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'main.dart';
import 'widgets/main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _displayText = "";
  final String _fullText = "CODE LOGIC";

  @override
  void initState() {
    super.initState();

    // 1. Native Splash turant hatao
    FlutterNativeSplash.remove();

    // 2. Pulse Animation setup (Neon glow effect ke liye)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Typing Effect Logic
    _startTyping();

    // 4. Navigation Timer
    Timer(const Duration(seconds: 3), () {
      checkLogin();
    });
  }

  void _startTyping() async {
    for (int i = 0; i <= _fullText.length; i++) {
      if (!mounted) return;
      setState(() {
        _displayText = _fullText.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void checkLogin() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const MainWrapper()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep dark theme
      body: Stack(
        children: [
          // Background subtle gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.05),
                  Colors.transparent,
                ],
                radius: 1.2,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Text
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Text(
                    _displayText,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: Colors.indigoAccent.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Terminal style blinking cursor
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigoAccent.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "INITIALIZING SYSTEM...",
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          // Bottom Progress bar animation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.indigoAccent.withOpacity(0.3),
              ),
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }
}
