import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../services/ad_service.dart';

// 🔥 Styled Section Header
Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15, top: 20),
    child: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.indigoAccent,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Matching Dark Background
        appBar: AppBar(
          title: Text("PLACEMENT MOCKS",
              style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18)),
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.indigoAccent,
            indicatorWeight: 4,
            labelColor: Colors.indigoAccent,
            unselectedLabelColor: Colors.white38,
            labelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "PRACTICE"),
              Tab(text: "COMPANY"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [TopicWiseView(), CompanyWiseView()],
        ),
      ),
    );
  }
}

class TopicWiseView extends StatelessWidget {
  const TopicWiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader("MASTER THE BASICS"),
        _buildCategoryCard(context, "Quantitative Aptitude", Icons.calculate,
            Colors.tealAccent, "Quant, Profit & Loss..."),
        _buildCategoryCard(context, "Logical Reasoning", Icons.psychology,
            Colors.purpleAccent, "Puzzles & Series..."),
        _buildCategoryCard(context, "Verbal Ability", Icons.menu_book,
            Colors.orangeAccent, "Grammar & Vocab..."),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon,
      Color color, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white38)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white24, size: 16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    QuizPlayScreen(category: title, isMixed: false))),
      ),
    );
  }
}

class CompanyWiseView extends StatelessWidget {
  const CompanyWiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader("TARGET TOP RECRUITERS"),
        _buildCompanyTile(context, "TCS NQT", Colors.blue),
        _buildCompanyTile(context, "Infosys", Colors.indigo),
        _buildCompanyTile(context, "Accenture", Colors.purple),
        _buildCompanyTile(context, "Amazon", Colors.orange),
      ],
    );
  }

  Widget _buildCompanyTile(BuildContext context, String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading:
            const Icon(Icons.business_rounded, color: Colors.white, size: 30),
        title: Text(name,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        subtitle: const Text("Premium Mocks & Pattern",
            style: TextStyle(color: Colors.white70, fontSize: 11)),
        trailing: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
        onTap: () => _showTcsDetailSheet(context, name),
      ),
    );
  }

  void _showTcsDetailSheet(BuildContext context, String company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$company Exam Pattern",
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 20),
                    _buildPatternRow(
                        "Verbal Ability", "24 Qs", Colors.greenAccent),
                    _buildPatternRow("Reasoning", "30 Qs", Colors.blueAccent),
                    _buildPatternRow("Numerical", "26 Qs", Colors.orangeAccent),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                        "💡 Focus on Time Management. No negative marking in foundation round.",
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const QuizPlayScreen(
                                      category: "Mixed", isMixed: true)));
                        },
                        child: const Text("START MOCK TEST",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternRow(String t, String d, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(Icons.check_circle_outline, color: c, size: 18),
            const SizedBox(width: 10),
            Text(t, style: const TextStyle(color: Colors.white, fontSize: 16))
          ]),
          Text(d, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class QuizPlayScreen extends StatefulWidget {
  final String category;
  final bool isMixed;
  const QuizPlayScreen(
      {super.key, required this.category, required this.isMixed});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  List<DocumentSnapshot> questions = [];
  bool isLoading = true;
  int currentIndex = 0;
  int score = 0;
  int timeLeft = 30;
  Timer? _timer;
  bool isAnswered = false;
  String selectedOption = "";

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    AdService.loadInterstitialAd();
  }

  Future<void> _fetchQuestions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('aptitude_questions').get();
    if (snapshot.docs.isNotEmpty) {
      questions = snapshot.docs.toList();
      questions.shuffle();
      questions = questions.take(10).toList();
    }
    if (mounted) setState(() => isLoading = false);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        if (mounted) setState(() => timeLeft--);
      } else {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (currentIndex < questions.length - 1) {
      if (mounted) {
        setState(() {
          currentIndex++;
          timeLeft = 30;
          isAnswered = false;
          selectedOption = "";
        });
      }
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    AdService.showInterstitialAd();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'points': FieldValue.increment(score * 10)});
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ResultScreen(score: score, total: questions.length)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(
              child: CircularProgressIndicator(color: Colors.indigoAccent)));
    }

    var data = questions[currentIndex].data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text("Question ${currentIndex + 1}/10",
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white10, borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text("⏱ $timeLeft",
                    style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / 10,
              backgroundColor: Colors.white10,
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: Text(data['question'],
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.5)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
            child: Column(
              children: [
                ...(data['options'] as List)
                    .map((opt) => _buildOption(opt, data['correctAnswer'])),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(String option, String correct) {
    bool isCorrect = option == correct;
    Color borderColor = isAnswered
        ? (isCorrect
            ? Colors.greenAccent
            : (option == selectedOption ? Colors.redAccent : Colors.white10))
        : Colors.white10;

    return GestureDetector(
      onTap: () {
        if (isAnswered) return;
        setState(() {
          isAnswered = true;
          selectedOption = option;
          if (isCorrect) score++;
        });
        Future.delayed(const Duration(milliseconds: 1000), _nextQuestion);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2),
          color: isAnswered && isCorrect
              ? Colors.greenAccent.withOpacity(0.05)
              : Colors.white.withOpacity(0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(option,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w500))),
            if (isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
            if (isAnswered && !isCorrect && option == selectedOption)
              const Icon(Icons.cancel_rounded, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  const ResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded,
                size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            Text("MISSION ACCOMPLISHED",
                style: GoogleFonts.orbitron(
                    color: Colors.indigoAccent,
                    letterSpacing: 2,
                    fontSize: 14)),
            const SizedBox(height: 10),
            Text("$score / $total",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold)),
            Text("Score +${score * 10} XP",
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 60),
            SizedBox(
              width: 200,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text("CONTINUE",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
