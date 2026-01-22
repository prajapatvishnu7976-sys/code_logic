import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_prep_pro/services/ad_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isPremium': true,
          'paymentId': response.paymentId,
          'purchaseDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        AdService.isPremiumUser = true;
        _showSuccessDialog();
      } catch (e) {
        debugPrint("Error saving payment: $e");
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle_outline,
            color: Colors.green, size: 60),
        content: const Text(
            "Premium Membership Activated! All resources are now unlocked.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK",
                  style: TextStyle(color: Colors.indigoAccent))),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  // 🔥 UPDATED: Force Auto-Capture via Config Logic
  void openCheckout() {
    final User? user = FirebaseAuth.instance.currentUser;

    var options = {
      'key': 'rzp_live_S1SIB9qif2h9V5',
      'amount': 19900, // ₹199 in paise
      'name': 'CODE LOGIC',
      'description': 'Lifetime Premium Access',

      // ✅ FORCE CAPTURE (Using both Int and String for safety)
      'payment_capture': '1',
      'capture': true,

      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': user?.phoneNumber ?? '', // User ka dynamic phone number
        'email': user?.email ?? '', // User ki dynamic email
      },
      'theme': {'color': '#6366F1'},
      'config': {
        'display': {
          'blocks': {
            'utp': {
              'name': 'Pay Securely',
              'instruments': [
                {'method': 'upi'},
                {'method': 'card'},
                {'method': 'netbanking'}
              ],
            },
          },
          'sequence': ['block.utp'],
          'preferences': {'show_default_blocks': true},
        },
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          bool isPremium = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            isPremium =
                (snapshot.data!.data() as Map<String, dynamic>)['isPremium'] ??
                    false;
            AdService.isPremiumUser = isPremium;
          }

          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Stack(
              children: [
                _buildBackgroundDecor(),
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildTopHeader(),
                          const SizedBox(height: 30),
                          isPremium
                              ? _buildAlreadyPremiumCard()
                              : _buildMainOfferCard(),
                          const SizedBox(height: 30),
                          _buildSectionTitle("Exclusive Benefits"),
                          const SizedBox(height: 15),
                          _buildFeatureGrid(),
                          const SizedBox(height: 30),
                          _buildSectionTitle("Frequently Asked Questions"),
                          _buildFAQTile("Is it really lifetime access?",
                              "Yes, pay ₹199 once and enjoy lifetime access to all premium materials."),
                          _buildFAQTile("Will I get job updates?",
                              "Yes! Premium users get special notifications for exclusive off-campus drives."),
                          const SizedBox(height: 200),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isPremium) _buildStickyPayButton(),
              ],
            ),
          );
        });
  }

  // --- UI WIDGETS ---
  Widget _buildAlreadyPremiumCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)])),
      child: Column(children: [
        const Icon(Icons.verified_user_rounded, color: Colors.white, size: 50),
        const SizedBox(height: 10),
        Text("You are a Pro Member!",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const Text("All premium features are unlocked for your account.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14)),
      ]),
    );
  }

  Widget _buildBackgroundDecor() {
    return Positioned(
        top: -100,
        right: -100,
        child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withOpacity(0.08))));
  }

  Widget _buildTopHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.4))),
          child: const Text("✨ CODE LOGIC",
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold))),
      const SizedBox(height: 15),
      Text("Unlock Your\nDream Career",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2)),
    ]);
  }

  Widget _buildMainOfferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("LIMITED TIME OFFER",
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 10),
        Row(children: [
          Text("₹199",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text("₹999",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 22,
                  decoration: TextDecoration.lineThrough)),
        ]),
        const Text("One-time payment for lifetime elite access.",
            style: TextStyle(color: Colors.white, fontSize: 14)),
      ]),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        "title": "Full DSA Path",
        "desc": "Topic-wise Code",
        "icon": Icons.code_rounded,
        "color": Colors.blueAccent
      },
      {
        "title": "Job Portal",
        "desc": "Off-campus Links",
        "icon": Icons.business_center_rounded,
        "color": Colors.greenAccent
      },
      {
        "title": "Premium Notes",
        "desc": "PDF Cheat Sheets",
        "icon": Icons.menu_book_rounded,
        "color": Colors.orangeAccent
      },
      {
        "title": "No Distractions",
        "desc": "Ad-free Learning",
        "icon": Icons.block_flipped,
        "color": Colors.redAccent
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5),
      itemCount: features.length,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(features[index]['icon'] as IconData,
                  color: features[index]['color'] as Color, size: 24),
              const SizedBox(height: 8),
              Text(features[index]['title'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Text(features[index]['desc'] as String,
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ]),
      ),
    );
  }

  Widget _buildFAQTile(String q, String a) {
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
            title: Text(q,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            children: [
              Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 12),
                  child: Text(a,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13)))
            ]));
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildStickyPayButton() {
    return Positioned(
      bottom: 105,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(children: [
              const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("₹199",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text("LIFETIME ACCESS",
                        style: TextStyle(color: Colors.white54, fontSize: 9)),
                  ]),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: openCheckout,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFA855F7)]),
                        borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.center,
                    child: const Text("UPGRADE NOW",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
