import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'question_detail_screen.dart'; // Detail screen import karna mat bhulna

class TopicQuestionsScreen extends StatelessWidget {
  final String topicName;

  const TopicQuestionsScreen({super.key, required this.topicName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "$topicName Problems",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 Database Query: Sirf selected topic ke questions lao

        stream: FirebaseFirestore.instance
            .collection('dsa_questions')
            .where('topic', isEqualTo: topicName)
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    "No Questions Added Yet!",
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Admin will upload soon.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var questions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              var q = questions[index].data() as Map<String, dynamic>;

              // Difficulty Colors

              Color diffColor = Colors.green;

              if (q['difficulty'] == 'Medium') diffColor = Colors.orange;

              if (q['difficulty'] == 'Hard') diffColor = Colors.red;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: diffColor.withOpacity(0.1),
                    child: Text(
                      q['title'][0].toUpperCase(),
                      style: TextStyle(
                        color: diffColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    q['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          q['difficulty'] ?? 'Easy',
                          style: TextStyle(
                            color: diffColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Navigate to Solution Screen

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionDetailScreen(
                          title: q['title'],
                          problemStatement: q['problem'] ?? "",
                          approach: q['approach'] ?? "",
                          codeCpp: q['cppCode'] ?? "",
                          codeJava: q['javaCode'] ?? "",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
