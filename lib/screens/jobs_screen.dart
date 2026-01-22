import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // 3 Tabs: All, Remote, Tech
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Error: $url');
    }
  }

  // 🔥 CUSTOM LOGO: Letter based professional avatars
  Widget _buildCompanyLogo(String companyName) {
    String letter = companyName.isNotEmpty ? companyName[0].toUpperCase() : "J";
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.indigoAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.indigoAccent.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.outfit(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
              top: -50,
              right: -50,
              child: _buildGlow(Colors.indigoAccent.withOpacity(0.15))),
          Positioned(
              bottom: 100,
              left: -50,
              child: _buildGlow(Colors.blueAccent.withOpacity(0.1))),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildSearchSection(),
                _buildModernTabBar(),
                Expanded(
                  child: user == null
                      ? const Center(
                          child: Text("Login Required",
                              style: TextStyle(color: Colors.white)))
                      : _buildAccessLogic(user.uid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Exclusive Jobs",
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
              Text("ELITE PORTAL",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
            ],
          ),
          _buildPremiumBadge(),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: Colors.black),
          SizedBox(width: 5),
          Text("PRO",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          decoration: const InputDecoration(
            hintText: "Search company or role...",
            hintStyle: TextStyle(color: Colors.white24),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.indigoAccent),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.indigoAccent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        tabs: const [
          Tab(text: "All Jobs"),
          Tab(text: "Remote"),
          Tab(text: "Tech"),
        ],
      ),
    );
  }

  Widget _buildAccessLogic(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var isPremium =
            (userSnap.data?.data() as Map<String, dynamic>?)?['isPremium'] ??
                false;

        if (!isPremium) return _buildLockedState();

        return TabBarView(
          controller: _tabController,
          children: [
            _buildJobsList("all"),
            _buildJobsList("remote"),
            _buildJobsList("tech"),
          ],
        );
      },
    );
  }

  Widget _buildJobsList(String filter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String role = data['role']?.toString().toLowerCase() ?? "";
          String company = data['company']?.toString().toLowerCase() ?? "";
          String location = data['location']?.toString().toLowerCase() ?? "";

          bool matchesSearch =
              role.contains(_searchQuery) || company.contains(_searchQuery);
          if (filter == "remote") {
            return matchesSearch && location.contains("remote");
          }
          return matchesSearch;
        }).toList();

        if (docs.isEmpty) {
          return const Center(
              child: Text("No jobs found",
                  style: TextStyle(color: Colors.white38)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildPremiumJobCard(data);
          },
        );
      },
    );
  }

  Widget _buildPremiumJobCard(Map<String, dynamic> data) {
    String companyName = data['company'] ?? "Company";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildCompanyLogo(companyName),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['role'] ?? 'Job Role',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(companyName,
                        style: GoogleFonts.poppins(
                            color: Colors.indigoAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(
                  Icons.location_on_outlined, data['location'] ?? "Remote"),
              _infoTile(Icons.currency_rupee_rounded,
                  data['salary'] ?? "Best in Class"),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(color: Colors.white10)),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _launchURL(data['link'] ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Apply Now",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildLockedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person_rounded,
              size: 80, color: Colors.amberAccent),
          const SizedBox(height: 20),
          Text("PREMIUM CONTENT",
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const Text("Upgrade to see verified job links",
              style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)
          ]),
    );
  }
}
