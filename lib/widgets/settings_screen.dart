import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 🔥 Privacy Policy Link (Play Store ke liye zaroori)
  // Baad mein apna Google Doc link yahan daal dena
  final String _privacyUrl = "https://www.google.com";

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // 🔥 Delete Account Logic (Google Requirement)
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      await AuthService().signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Deleted Successfully")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Login again to delete account. $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "General",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildTile(
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {
              // Profile Edit logic (Optional)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Coming Soon!")));
            },
          ),
          _buildTile(
            icon: Icons.notifications_none,
            title: "Notifications",
            trailing: Switch(value: true, onChanged: (val) {}), // Dummy Switch
            onTap: () {},
          ),

          const SizedBox(height: 30),
          const Text(
            "Legal & Support",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () => _launchURL(_privacyUrl),
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: "About Us",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "SmartPrep Pro",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 SmartPrep Inc.",
              );
            },
          ),

          const SizedBox(height: 30),
          const Text(
            "Danger Zone",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _buildTile(
            icon: Icons.delete_forever,
            title: "Delete Account",
            color: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Account?"),
                  content: const Text(
                    "This action cannot be undone. All your progress and premium status will be lost.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteAccount(context);
                      },
                      child: const Text(
                        "DELETE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color color = Colors.black87,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        trailing:
            trailing ??
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
