import 'package:flutter/material.dart';

// ✅ Sahi folder paths use kiye hain tumhare structure ke hisab se
import '../widgets/admin_interview_job_screen.dart';
import '../widgets/admin_aptitude_screen.dart';
import '../widgets/admin_notification_screen.dart';
import '../widgets/admin_dsa_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 15),

          // 🏢 1. MANAGE JOBS & EXPERIENCES
          _buildAdminTile(
            context,
            title: "Manage Jobs & Experiences",
            subtitle: "Upload real company data & job openings",
            icon: Icons.business_center,
            color: Colors.blueAccent,
            page: const AdminInterviewJobScreen(),
          ),

          // 📝 2. MANAGE APTITUDE
          _buildAdminTile(
            context,
            title: "Upload Aptitude & Mock Tests",
            subtitle: "Add Quant, Logical & Verbal questions",
            icon: Icons.quiz,
            color: Colors.teal,
            page: const AdminAptitudeScreen(),
          ),

          // 🔔 3. SEND NOTIFICATIONS
          _buildAdminTile(
            context,
            title: "Push Notifications",
            subtitle: "Send alerts for new jobs or app updates",
            icon: Icons.notifications_active,
            color: Colors.orange,
            page: const AdminNotificationScreen(),
          ),

          // 💻 4. MANAGE DSA
          _buildAdminTile(
            context,
            title: "Manage DSA Content",
            subtitle: "Add or edit DSA sheets and logic",
            icon: Icons.code,
            color: Colors.purple,
            page: const AdminDsaScreen(),
          ),

          const SizedBox(height: 30),
          const Center(
            child: Column(
              children: [
                Icon(Icons.shield, color: Colors.grey, size: 30),
                SizedBox(height: 5),
                Text(
                  "SmartPrep Pro Admin v2.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🛠️ Tile Helper (Purana Design)
  Widget _buildAdminTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
