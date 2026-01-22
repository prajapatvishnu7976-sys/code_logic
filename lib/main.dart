import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ SERVICES imports
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'splash_screen.dart';

// ✅ SCREENS imports
import 'widgets/main_wrapper.dart';

void main() async {
  // 🔥 WidgetsBinding ensure karna zaroori hai initialization se pehle
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Note: Humne preserve() ko comment kiya hai taaki Native Splash jaldi hate
  // aur hamara animated splash screen turant load ho.
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp();

    // 💰 Ads & Notifications Initialization
    await MobileAds.instance.initialize();
    AdService.loadInterstitialAd();
    AdService.loadRewardedAd();
    await NotificationService().init();
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }

  runApp(const SmartPrepApp());
}

class SmartPrepApp extends StatelessWidget {
  const SmartPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CODE LOGIC',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // ✅ Global Font Set
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      // App yahan se start hogi
      home: const SplashScreen(),
    );
  }
}

// ✅ LOGIN SCREEN (Full UI with Logic)
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Background
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🚀 Animated Logo Box
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Image.asset(
                  'assets/app_icon.png',
                  height: 90,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.code_rounded,
                      size: 80,
                      color: Colors.indigoAccent),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // App Name & Tagline
            Text(
              "CODE LOGIC",
              style: GoogleFonts.orbitron(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Master DSA with logic, not just code.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 80),

            // ✅ Google Login Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          final user = await AuthService().signInWithGoogle();
                          if (user != null) {
                            _navigateHome();
                          } else {
                            setState(() => isLoading = false);
                          }
                        } catch (e) {
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Login Failed. Please try again.")),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 40),
                          const SizedBox(width: 8),
                          Text(
                            "Continue with Google",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
            // Footer Text
            Text(
              "By continuing, you agree to our Terms & Conditions",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }
}
