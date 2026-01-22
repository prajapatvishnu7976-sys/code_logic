import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String title;
  final String problemStatement;
  final String approach;
  final String codeCpp;
  final String codeJava;

  const QuestionDetailScreen({
    super.key,
    required this.title,
    required this.problemStatement,
    required this.approach,
    required this.codeCpp,
    required this.codeJava,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light Premium Background
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "C++ Solution", icon: Icon(Icons.code)),
            Tab(text: "Java Solution", icon: Icon(Icons.coffee)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSolutionView(widget.codeCpp, "C++"),
          _buildSolutionView(widget.codeJava, "Java"),
        ],
      ),
    );
  }

  Widget _buildSolutionView(String code, String lang) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Problem Statement Section ---
          _buildSectionHeader(
              Icons.help_outline, "Problem Statement", Colors.orange),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.problemStatement,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF1E293B), // Deep Blue Grey (Super Clear)
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // --- Logic / Approach Section ---
          _buildSectionHeader(
              Icons.lightbulb_outline, "Logic & Approach", Colors.green),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.1)),
            ),
            child: Text(
              widget.approach,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF334155), // Slate Grey
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // --- Code Section ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(Icons.terminal, "$lang Code", Colors.indigo),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$lang Code Copied!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.indigo,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_all, color: Colors.indigo),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Dark Code Editor Background
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF38BDF8), // Light Blue (VS Code style)
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
