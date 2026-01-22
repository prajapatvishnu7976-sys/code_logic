import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// 1️⃣ MAIN APTITUDE CATEGORY SCREEN
class AptitudeScreen extends StatelessWidget {
  const AptitudeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "APTITUDE & REASONING",
          style: GoogleFonts.orbitron(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCategoryCard(
              context,
              "Quantitative Aptitude",
              Icons.calculate_rounded,
              Colors.orangeAccent,
              "Maths & Calculations"),
          _buildCategoryCard(context, "Logical Reasoning",
              Icons.psychology_rounded, Colors.purpleAccent, "Logic & Puzzles"),
          _buildCategoryCard(context, "Verbal Ability", Icons.menu_book_rounded,
              Colors.blueAccent, "English & Grammar"),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon,
      Color color, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white24, size: 18),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AptitudeTopicScreen(category: title))),
      ),
    );
  }
}

// 2️⃣ TOPIC SELECTION SCREEN
class AptitudeTopicScreen extends StatelessWidget {
  final String category;
  const AptitudeTopicScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(category.toUpperCase(),
            style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('aptitude_questions')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.indigoAccent));
          }

          var docs = snapshot.data!.docs;
          Set<String> topics = docs.map((d) => d['topic'] as String).toSet();

          if (topics.isEmpty) {
            return const Center(
                child: Text("No topics found yet.",
                    style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              String topic = topics.elementAt(index);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.bolt_rounded, color: Colors.amberAccent),
                  title: Text(topic,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.play_circle_fill_rounded,
                      color: Colors.indigoAccent),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AptitudePracticeScreen(
                              category: category, topic: topic))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 3️⃣ PRACTICE SCREEN (QUESTIONS & ANSWERS)
class AptitudePracticeScreen extends StatefulWidget {
  final String category;
  final String topic;
  const AptitudePracticeScreen(
      {super.key, required this.category, required this.topic});

  @override
  State<AptitudePracticeScreen> createState() => _AptitudePracticeScreenState();
}

class _AptitudePracticeScreenState extends State<AptitudePracticeScreen> {
  Set<String> revealedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.topic,
            style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('aptitude_questions')
            .where('category', isEqualTo: widget.category)
            .where('topic', isEqualTo: widget.topic)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var questions = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              var data = questions[index].data() as Map<String, dynamic>;
              String docId = questions[index].id;
              List<dynamic> options = data['options'] ?? [];
              bool isRevealed = revealedAnswers.contains(docId);

              return Container(
                margin: const EdgeInsets.only(bottom: 25),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Question ${index + 1}",
                        style: GoogleFonts.poppins(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(data['question'],
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    ...options
                        .map((opt) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle_outlined,
                                      size: 14, color: Colors.white24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(opt.toString(),
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14))),
                                ],
                              ),
                            ))
                        ,
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => setState(() => isRevealed
                          ? revealedAnswers.remove(docId)
                          : revealedAnswers.add(docId)),
                      icon: Icon(
                          isRevealed ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: Colors.indigoAccent),
                      label: Text(isRevealed ? "Hide Answer" : "Show Answer",
                          style: const TextStyle(color: Colors.indigoAccent)),
                    ),
                    if (isRevealed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CORRECT ANSWER: ${data['correctAnswer']}",
                                style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold)),
                            const Divider(color: Colors.white10, height: 20),
                            const Text("Explanation:",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            const SizedBox(height: 5),
                            Text(data['explanation'] ?? "No explanation.",
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
