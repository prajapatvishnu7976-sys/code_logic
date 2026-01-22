import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyDetailScreen extends StatelessWidget {
  final String companyName;
  const CompanyDetailScreen({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("$companyName Guide 🚀",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 SECTION 1: EXAM PATTERN
            _buildHeader("Latest Exam Pattern (2025)"),
            _buildPatternCard("Foundation Round",
                "Numerical (26Q), Verbal (24Q), Reasoning (30Q)"),
            _buildPatternCard("Advanced Round",
                "Adv. Quant (10Q), Adv. Reasoning (10Q), Coding (2Q)"),

            const SizedBox(height: 25),

            // 🎯 SECTION 2: TOPIC WEIGHTAGE
            _buildHeader("High Priority Topics"),
            Wrap(
              spacing: 10,
              children: [
                _buildTopicChip("Time & Work", Colors.teal),
                _buildTopicChip("Profit & Loss", Colors.orange),
                _buildTopicChip("Data Interpretation", Colors.blue),
                _buildTopicChip("Syllogism", Colors.purple),
              ],
            ),

            const SizedBox(height: 25),

            // 💡 SECTION 3: SMART HACKS (PREMIUM)
            _buildHeader("Premium Strategy & Hacks"),
            _buildHackTile("No Negative Marking",
                "Attempt all questions, even if you guess."),
            _buildHackTile(
                "LCM Method", "Use LCM for Time & Work questions to save 40s."),
            _buildHackTile(
                "STAR Technique", "Use STAR method for HR Interview answers."),

            const SizedBox(height: 30),

            // 🚀 ACTION BUTTONS
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("START TCS PRACTICE TEST"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Link to QuizPlayScreen with TCS category
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B))),
    );
  }

  Widget _buildPatternCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 5),
          Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label, Color color) {
    return Chip(
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      elevation: 0,
    );
  }

  Widget _buildHackTile(String title, String desc) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.lightbulb, color: Colors.amber),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
    );
  }
}
