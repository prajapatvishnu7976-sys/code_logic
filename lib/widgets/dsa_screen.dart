import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'topic_questions_screen.dart';

class DsaScreen extends StatelessWidget {
  const DsaScreen({super.key});

  final List<Map<String, dynamic>> dsaTopics = const [
    {"title": "Arrays", "icon": Icons.data_array, "color": Colors.blueAccent},
    {
      "title": "Strings",
      "icon": Icons.text_fields,
      "color": Colors.orangeAccent
    },
    {"title": "Linked List", "icon": Icons.link, "color": Colors.purpleAccent},
    {
      "title": "Searching & Sorting",
      "icon": Icons.search,
      "color": Colors.greenAccent
    },
    {
      "title": "Binary Trees",
      "icon": Icons.account_tree,
      "color": Colors.tealAccent
    },
    {"title": "DP", "icon": Icons.dynamic_form, "color": Colors.redAccent},
    {"title": "Graphs", "icon": Icons.hub, "color": Colors.deepPurpleAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Background
      appBar: AppBar(
        title: Text(
          "DSA SHEETS ⚡",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        physics: const BouncingScrollPhysics(),
        itemCount: dsaTopics.length,
        itemBuilder: (context, index) {
          final topic = dsaTopics[index];
          final Color topicColor = topic['color'];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: topicColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(topic['icon'], color: topicColor, size: 28),
              ),
              title: Text(
                topic['title'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              subtitle: const Text(
                "Master handpicked questions",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: topicColor.withOpacity(0.5),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TopicQuestionsScreen(topicName: topic['title']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
