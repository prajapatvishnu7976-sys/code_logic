import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDailyQuizScreen extends StatefulWidget {
  const AdminDailyQuizScreen({super.key});

  @override
  State<AdminDailyQuizScreen> createState() => _AdminDailyQuizScreenState();
}

class _AdminDailyQuizScreenState extends State<AdminDailyQuizScreen> {
  final _questionController = TextEditingController();
  final _opt1 = TextEditingController();
  final _opt2 = TextEditingController();
  final _opt3 = TextEditingController();
  final _opt4 = TextEditingController();
  final _correctAns = TextEditingController();

  void _uploadDailyQuiz() async {
    if (_questionController.text.isEmpty || _correctAns.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('daily_quiz').doc('today').set({
      'question': _questionController.text,
      'options': [_opt1.text, _opt2.text, _opt3.text, _opt4.text],
      'correctAnswer': _correctAns.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Daily Quiz Updated & Sent!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Daily Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: "Question of the Day",
              ),
            ),
            TextField(
              controller: _opt1,
              decoration: const InputDecoration(labelText: "Option 1"),
            ),
            TextField(
              controller: _opt2,
              decoration: const InputDecoration(labelText: "Option 2"),
            ),
            TextField(
              controller: _opt3,
              decoration: const InputDecoration(labelText: "Option 3"),
            ),
            TextField(
              controller: _opt4,
              decoration: const InputDecoration(labelText: "Option 4"),
            ),
            TextField(
              controller: _correctAns,
              decoration: const InputDecoration(
                labelText: "Correct Answer (Must match an option)",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _uploadDailyQuiz,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Update Quiz & Notify All"),
            ),
          ],
        ),
      ),
    );
  }
}
