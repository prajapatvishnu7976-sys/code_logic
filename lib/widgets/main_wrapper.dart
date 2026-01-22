import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'premium_screen.dart';
import 'profile_screen.dart';
import 'package:smart_prep_pro/services/ad_service.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _checkPremiumStatus(); // ✅ App start hote hi check karo
  }

  // 🛡️ Firebase se Premium Status mangwao
  Future<void> _checkPremiumStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()?['isPremium'] == true) {
          setState(() {
            isPremium = true;
            AdService.isPremiumUser = true; // Ads disable kar do
          });
        }
      } catch (e) {
        debugPrint("Error checking premium: $e");
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              HomeScreen(
                key: const ValueKey('home'),
                userImage: user?.photoURL ?? "",
              ),
              ExploreScreen(
                key: const ValueKey('explore'),
                onUpgradeTap: (index) => _onNavItemTapped(index),
              ),
              const PremiumScreen(key: ValueKey('premium')),
              const ProfileScreen(key: ValueKey('profile')),
            ],
          ),

          // Glassmorphic Nav Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(Icons.home_rounded, "Home", 0),
                      _navItem(Icons.explore_rounded, "Explore", 1),
                      _navItem(Icons.workspace_premium_rounded, "Premium", 2,
                          isSpecial: true),
                      _navItem(Icons.person_rounded, "Profile", 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index,
      {bool isSpecial = false}) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? (isSpecial ? Colors.amberAccent : Colors.indigoAccent)
                : Colors.white38,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
