import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/quiz_screen.dart';

class RoadmapScreen extends StatelessWidget {
  final int currentDay;
  const RoadmapScreen({super.key, required this.currentDay});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> phases = [
      {
        "step": "01",
        "title": "Language Mastery",
        "desc": "C++/Java & OOPs fundamentals."
      },
      {
        "step": "02",
        "title": "Data Structures",
        "desc": "Arrays to Graphs (Striver's Sheet)."
      },
      {
        "step": "03",
        "title": "CS Fundamentals",
        "desc": "OS, DBMS & Networking concepts."
      },
      {
        "step": "04",
        "title": "Major Projects",
        "desc": "Full Stack Development & Deployment."
      },
      {
        "step": "05",
        "title": "Aptitude & Mocks",
        "desc": "Company specific mock rounds."
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("MY ROADMAP",
            style: GoogleFonts.orbitron(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            for (int i = 0; i < phases.length; i++)
              _buildTimelineStep(
                context,
                phases[i]['step'],
                phases[i]['title'],
                phases[i]['desc'],
                isCompleted: currentDay > (i + 1) * 6,
                isLocked: currentDay < (i * 6) + 1,
                isLast: i == phases.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
      BuildContext context, String step, String title, String desc,
      {required bool isCompleted,
      bool isLocked = false,
      required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isLocked)
                    BoxShadow(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.3)
                            : Colors.indigo.withOpacity(0.3),
                        blurRadius: 15)
                ],
                gradient: isLocked
                    ? null
                    : LinearGradient(
                        colors: isCompleted
                            ? [Colors.green, Colors.teal]
                            : [
                                const Color(0xFF6366F1),
                                const Color(0xFF4338CA)
                              ]),
                color: isLocked ? Colors.white10 : null,
              ),
              child: Icon(
                  isLocked
                      ? Icons.lock_outline
                      : (isCompleted ? Icons.check_circle : Icons.bolt),
                  color: Colors.white,
                  size: 20),
            ),
            if (!isLast)
              Container(
                  width: 2,
                  height: 100,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    isCompleted ? Colors.green : Colors.white10,
                    Colors.white10
                  ]))),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isLocked ? Colors.transparent : Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: isLocked ? Colors.white24 : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(desc,
                    style: TextStyle(
                        color: isLocked ? Colors.white12 : Colors.white54,
                        fontSize: 13)),
                if (!isLocked && !isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        // Proof-of-work logic
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QuizScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text("TAKE PHASE TEST"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
