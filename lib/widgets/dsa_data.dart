import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Apne detail screen ka path yahan sahi kar lena
// import 'package:smart_prep_pro/screens/dsa_detail_screen.dart';

class TopicQuestionsScreen extends StatefulWidget {
  final String topicName;
  const TopicQuestionsScreen({super.key, required this.topicName});

  @override
  State<TopicQuestionsScreen> createState() => _TopicQuestionsScreenState();
}

class _TopicQuestionsScreenState extends State<TopicQuestionsScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Firestore mein progress save karne ke liye
  void _toggleQuestionProgress(String questionId, bool currentStatus) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dsa_progress')
        .doc(questionId)
        .set({'isDone': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Rich Dark Navy
      appBar: AppBar(
        title: Text(
          widget.topicName.toUpperCase(),
          style: GoogleFonts.orbitron(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 Real-time data from Firestore
        stream: FirebaseFirestore.instance
            .collection('dsa_questions')
            .where('topic', isEqualTo: widget.topicName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Error loading data",
                    style: TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.indigoAccent));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text("No questions added yet for this topic.",
                  style: GoogleFonts.poppins(color: Colors.white38)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var questionData = docs[index].data() as Map<String, dynamic>;
              String qId = docs[index].id;
              String diff = questionData['difficulty'] ?? "Easy";

              // Premium Color Palette
              Color diffColor = const Color(0xFF10B981); // Emerald Green
              if (diff == "Medium") {
                diffColor = const Color(0xFFF59E0B); // Amber
              }
              if (diff == "Hard") diffColor = const Color(0xFFEF4444); // Red

              return StreamBuilder<DocumentSnapshot>(
                // 🔥 Individual question progress stream
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('dsa_progress')
                    .doc(qId)
                    .snapshots(),
                builder: (context, progSnap) {
                  bool isDone = false;
                  if (progSnap.hasData && progSnap.data!.exists) {
                    isDone = (progSnap.data!.data()
                            as Map<String, dynamic>)['isDone'] ??
                        false;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      onTap: () {
                        // 🔥 NEXT STEP: Navigation to Detail Screen
                        // Navigator.push(context, MaterialPageRoute(builder: (c) => DSADetailScreen(questionData: questionData)));
                      },
                      leading: GestureDetector(
                        onTap: () => _toggleQuestionProgress(qId, isDone),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? Colors.greenAccent.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color:
                                  isDone ? Colors.greenAccent : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 18,
                            color: isDone
                                ? Colors.greenAccent
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      title: Text(
                        questionData['title'] ?? "Untitled Question",
                        style: GoogleFonts.poppins(
                          color: isDone ? Colors.white38 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            _buildBadge(diff, diffColor),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white10, size: 14),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
