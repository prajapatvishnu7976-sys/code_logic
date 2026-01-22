import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:smart_prep_pro/widgets/main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  void _navigateHome() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.indigoAccent,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 🌌 Background Glow Effect (Adjusted)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withOpacity(0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🚀 Icon Section with subtle glow
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.indigoAccent.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 80,
                    color: Colors.indigoAccent,
                  ),
                ),

                const SizedBox(height: 40),

                // 🖋️ Updated Title (Added Shadows for Visibility)
                Text(
                  "SmartPrep Pro",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 32, // Size thoda bada kiya
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.indigoAccent.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                      const Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // 📝 Subtitle
                Text(
                  "Your ultimate placement companion.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70, // Thoda aur bright kiya
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 100),

                // 📱 Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      try {
                        await AuthService().signInWithGoogle();
                        _navigateHome();
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Login Failed: ${e.toString()}")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 10, // Shadow add kiya button par
                      shadowColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.g_mobiledata_rounded,
                            size: 45, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text(
                          "Continue with Google",
                          style: GoogleFonts.poppins(
                            fontSize: 17, // Font size thoda bada kiya
                            fontWeight: FontWeight.w700,
                            color: Colors.black, // Pura black rakha hai
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔒 Privacy Note
                Text(
                  "By continuing, you agree to our Terms & Privacy",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
