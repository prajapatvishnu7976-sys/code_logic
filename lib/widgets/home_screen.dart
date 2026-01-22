import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Services & Screens
import '../services/ad_service.dart';
import '../widgets/roadmap_screen.dart';
import '../widgets/quiz_screen.dart';
import '../widgets/dsa_screen.dart';
import '../screens/jobs_screen.dart';
import '../screens/leaderboard_screen.dart';
import 'aptitude_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userImage;
  const HomeScreen({super.key, required this.userImage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";
  double _buttonScale = 1.0;

  // 🛡️ Universal Navigation Handler
  void _handleNavigation(Widget screen, bool isLocked) {
    if (isLocked && !AdService.isPremiumUser) {
      _showPremiumLockDialog();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  void _showPremiumLockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.amberAccent),
            SizedBox(width: 10),
            Text("Premium Feature",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Upgrade to Premium to unlock Jobs, Daily Challenges and more exclusive resources.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PremiumScreen()));
            },
            child:
                const Text("VIEW PLANS", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonScale = 0.94),
      onTapUp: (_) => setState(() => _buttonScale = 1.0),
      onTapCancel: () => setState(() => _buttonScale = 1.0),
      onTap: onTap,
      child: AnimatedScale(
        scale: _buttonScale,
        duration: const Duration(milliseconds: 150),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Scaffold(body: Center(child: Text("Please Login")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Color(0xFF0F172A),
              body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final int currentDay = data['currentDay'] ?? 1;
        final int points = data['points'] ?? 0;
        final String name = data['name'] ?? "User";

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              _buildGlowPositioned(),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),
                      _buildHeader(name, points),
                      const SizedBox(height: 30),
                      _buildRoadmapCard(currentDay),
                      const SizedBox(height: 35),
                      _buildSectionLabel("Learning Modules"),
                      const SizedBox(height: 20),
                      _buildActionGrid(), // ✅ Jobs locked here
                      const SizedBox(height: 30),
                      _buildDailyStreak(
                          context), // ✅ Daily Challenge locked here
                      const SizedBox(height: 140),
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

  Widget _buildHeader(String name, int points) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Level Up,",
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildXPBadge(points),
      ],
    );
  }

  Widget _buildXPBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amberAccent.withOpacity(0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 20),
        const SizedBox(width: 6),
        Text("$points XP",
            style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildRoadmapCard(int day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF3730A3)])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("30 DAYS CHALLENGE",
            style: GoogleFonts.orbitron(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Text("Day $day Progress",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: day / 30,
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 10)),
        const SizedBox(height: 25),
        _buildAnimatedButton(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RoadmapScreen(currentDay: day))),
          child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center,
              child: Text("RESUME JOURNEY",
                  style: GoogleFonts.orbitron(
                      color: const Color(0xFF3730A3),
                      fontWeight: FontWeight.bold,
                      fontSize: 13))),
        ),
      ]),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 1.3,
      children: [
        _buildModuleItem("DSA", Icons.terminal_rounded, Colors.cyanAccent,
            const DsaScreen(), false), // ✅ Always Open
        _buildModuleItem(
            "APTITUDE",
            Icons.psychology_rounded,
            Colors.orangeAccent,
            const AptitudeScreen(),
            false), // ✅ Always Open
        _buildModuleItem("JOBS", Icons.work_rounded, Colors.greenAccent,
            const JobsScreen(), true), // 🔒 Premium Only
        _buildModuleItem("RANK", Icons.leaderboard_rounded, Colors.pinkAccent,
            const LeaderboardScreen(), false), // ✅ Always Open
      ],
    );
  }

  Widget _buildModuleItem(String title, IconData icon, Color color,
      Widget screen, bool needsPremium) {
    // Feature tabhi locked dikhega jab user premium nahi hai AUR feature premium wala hai
    bool isLocked = needsPremium && !AdService.isPremiumUser;

    return _buildAnimatedButton(
      onTap: () => _handleNavigation(screen, needsPremium),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: isLocked ? Colors.white24 : color, size: 34),
                  const SizedBox(height: 12),
                  Text(title,
                      style: GoogleFonts.orbitron(
                          color: isLocked ? Colors.white24 : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11)),
                ],
              ),
            ),
            if (isLocked)
              const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(Icons.lock_outline_rounded,
                      color: Colors.amberAccent, size: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStreak(BuildContext context) {
    bool isLocked =
        !AdService.isPremiumUser; // 🔒 Daily Challenge is always Premium
    return _buildAnimatedButton(
      onTap: () => _handleNavigation(const QuizScreen(), true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.white.withOpacity(0.02)
              : Colors.orangeAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isLocked
                  ? Colors.white10
                  : Colors.orangeAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.flash_on_rounded,
                color: isLocked ? Colors.white24 : Colors.orangeAccent,
                size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("DAILY CHALLENGE",
                      style: GoogleFonts.orbitron(
                          color: isLocked ? Colors.white24 : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Text(
                      isLocked
                          ? "Premium Members Only"
                          : "Test your skills and earn XP",
                      style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            Icon(isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: isLocked ? Colors.amberAccent : Colors.orangeAccent,
                size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text,
      style: GoogleFonts.orbitron(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
  Widget _buildGlowPositioned() => Stack(children: [
        Positioned(
            top: -50,
            left: -50,
            child:
                _buildGlowCircle(Colors.indigoAccent.withOpacity(0.12), 250)),
        Positioned(
            bottom: 100,
            right: -50,
            child: _buildGlowCircle(Colors.purpleAccent.withOpacity(0.08), 200))
      ]);
  Widget _buildGlowCircle(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)
      ]));
}
