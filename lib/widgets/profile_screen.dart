import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTANT: Imports check karlo (Kyuki LoginScreen main.dart mein hai)
import '../main.dart';
import 'package:smart_prep_pro/screens/leaderboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "Learner";
  }

  // --- 🔔 COMING SOON SNACKBAR ---
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Purana Snackbar hatao
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature feature is coming soon! 🚀",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigoAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- 🔥 LOGOUT LOGIC (Fixed) ---
  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.indigoAccent)),
      );

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pop(context); // Dialog hatao
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showComingSoon("Error: $e");
    }
  }

  // --- SAVE CHANGES LOGIC ---
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await user?.updateDisplayName(_nameController.text.trim());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'name': _nameController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile Updated! ✅"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showComingSoon("Update failed");
    }
    setState(() => _isLoading = false);
  }

  // --- SETTINGS MODAL ---
  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("App Settings",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined,
                  color: Colors.indigoAccent),
              title: const Text("Push Notifications",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon("Notifications");
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_rounded,
                  color: Colors.indigoAccent),
              title: const Text("Privacy & Security",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon("Privacy");
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String points = "0", rank = "---", streak = "0";
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            points = (data['points'] ?? 0).toString();
            rank = "#${data['rank'] ?? '---'}";
            streak = "${data['streak'] ?? 0} Days";
          }

          String firstLetter = _nameController.text.isNotEmpty
              ? _nameController.text[0].toUpperCase()
              : "L";

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(firstLetter, points, rank, streak),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("ACCOUNT INFORMATION"),
                      const SizedBox(height: 15),
                      _buildField("Display Name", _nameController,
                          Icons.person_rounded),
                      const SizedBox(height: 15),
                      _buildField(
                          "Email Address",
                          TextEditingController(text: user?.email),
                          Icons.email_rounded,
                          enabled: false),

                      const SizedBox(height: 35),
                      _buildLabel("QUICK ACTIONS"),
                      const SizedBox(height: 15),

                      // 🏆 LEADERBOARD (Yeh chalta hai)
                      _buildTile("Leaderboard Status",
                          Icons.emoji_events_rounded, Colors.amber, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LeaderboardScreen()));
                      }),

                      // 📊 COMING SOON ACTIONS
                      _buildTile(
                          "My Progress Graph",
                          Icons.auto_graph_rounded,
                          Colors.blueAccent,
                          () => _showComingSoon("Progress Graph")),
                      _buildTile(
                          "Study Certificates",
                          Icons.card_membership_rounded,
                          Colors.purpleAccent,
                          () => _showComingSoon("Certificates")),
                      _buildTile("System Settings", Icons.settings_rounded,
                          Colors.grey, _openSettings),

                      const SizedBox(height: 40),
                      _buildSaveBtn(),
                      const SizedBox(height: 15),
                      _buildLogoutBtn(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      String letter, String points, String rank, String streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Colors.indigoAccent, Colors.purpleAccent]),
              boxShadow: [
                BoxShadow(
                    color: Colors.indigoAccent.withOpacity(0.3), blurRadius: 20)
              ],
            ),
            child: Center(
                child: Text(letter,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 20),
          Text(_nameController.text.toUpperCase(),
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(rank, "RANK"),
              _buildStat(points, "XP"),
              _buildStat(streak, "STREAK"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(children: [
      Text(val,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label,
          style: const TextStyle(
              color: Colors.white38, fontSize: 9, letterSpacing: 1)),
    ]);
  }

  Widget _buildTile(String t, IconData i, Color c, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(i, color: c, size: 22),
        title:
            Text(t, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white24, size: 14),
      ),
    );
  }

  Widget _buildLabel(String l) => Text(l,
      style: GoogleFonts.poppins(
          color: Colors.indigoAccent,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1));

  Widget _buildField(String l, TextEditingController c, IconData i,
      {bool enabled = true}) {
    return TextField(
      controller: c,
      enabled: enabled,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: l,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(i, color: Colors.indigoAccent, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSaveBtn() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("SAVE CHANGES",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLogoutBtn() {
    return Center(
      child: TextButton.icon(
        onPressed: _handleLogout,
        icon:
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
        label: const Text("Logout Session",
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
