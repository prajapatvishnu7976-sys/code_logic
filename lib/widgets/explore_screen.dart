import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResourceItem {
  final String title;
  final String subTitle;
  final String category;
  final String url;
  final IconData icon;
  final Color color;

  ResourceItem({
    required this.title,
    required this.subTitle,
    required this.category,
    required this.url,
    required this.icon,
    required this.color,
  });
}

class ExploreScreen extends StatefulWidget {
  final Function(int)? onUpgradeTap;
  const ExploreScreen({super.key, this.onUpgradeTap});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<ResourceItem> allResources = [
    ResourceItem(
        title: "Striver's DSA",
        subTitle: "A2Z Playlist for FAANG",
        category: "DSA",
        url:
            "https://www.youtube.com/watch?v=0bHoB32fuj0&list=PLgUwDviBIf0oF6QL8m22w1hIDC1vJ_BHz",
        icon: Icons.code_rounded,
        color: Colors.blueAccent),
    ResourceItem(
        title: "Love Babbar DSA",
        subTitle: "Supreme Placement Series",
        category: "DSA",
        url:
            "https://www.youtube.com/watch?v=WQoB2z67hvY&list=PLDzeHZWIZsTryvtXdMr6rPh4IDexB5NIA",
        icon: Icons.terminal_rounded,
        color: Colors.redAccent),
    ResourceItem(
        title: "Web Development",
        subTitle: "MERN Stack - CodeWithHarry",
        category: "Web",
        url:
            "https://www.youtube.com/watch?v=tVzUXW6siu0&list=PLu0W_9lII9agq5TrH9XLIKQvv0iaF2X3w",
        icon: Icons.html_rounded,
        color: Colors.orangeAccent),
    ResourceItem(
        title: "Flutter Mastery",
        subTitle: "App Dev by Codepur",
        category: "Android",
        url: "https://www.youtube.com/watch?v=j-LOab_PzzU",
        icon: Icons.android_rounded,
        color: Colors.greenAccent),
    ResourceItem(
        title: "Java & DSA",
        subTitle: "Kunal Kushwaha Series",
        category: "DSA",
        url:
            "https://www.youtube.com/watch?v=rZ41y93P2Qo&list=PL9gnSGHSqcnr_DxHsP7AW9ftq0AtAyYqJ",
        icon: Icons.coffee_rounded,
        color: Colors.brown),
    ResourceItem(
        title: "Generative AI",
        subTitle: "Google Cloud Training",
        category: "AI",
        url: "https://www.youtube.com/watch?v=cZaNf2rA30k",
        icon: Icons.psychology_rounded,
        color: Colors.purpleAccent),
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch resource link.")));
      }
    }
  }

  void _showPremiumModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.amber, size: 60),
            const SizedBox(height: 20),
            Text("Premium Access Required",
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            const Text(
                "This curated resource is exclusively available for Pro members. Upgrade now to unlock all educational content.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onUpgradeTap != null) widget.onUpgradeTap!(2);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text("UPGRADE TO PRO",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          bool isPremium = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            isPremium =
                (snapshot.data!.data() as Map<String, dynamic>)['isPremium'] ??
                    false;
          }

          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Learning Roadmaps"),
                          const SizedBox(height: 15),
                          _buildRoadmapCards(),
                          const SizedBox(height: 30),
                          _buildSectionTitle("Curated Resources"),
                          const SizedBox(height: 15),
                          _buildResourceGrid(isPremium), // Pass status
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Explore Hub",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          const Text("Access high-quality learning materials",
              style: TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildRoadmapCards() {
    final List<Map<String, dynamic>> roadmaps = [
      {
        "name": "Frontend",
        "icon": Icons.palette_rounded,
        "col": Colors.orangeAccent,
        "url": "https://roadmap.sh/frontend"
      },
      {
        "name": "Backend",
        "icon": Icons.dns_rounded,
        "col": Colors.blueAccent,
        "url": "https://roadmap.sh/backend"
      },
      {
        "name": "DevOps",
        "icon": Icons.all_inclusive_rounded,
        "col": Colors.purpleAccent,
        "url": "https://roadmap.sh/devops"
      },
    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: roadmaps.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _launchURL(roadmaps[index]['url']),
          child: Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
                color: (roadmaps[index]['col'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: (roadmaps[index]['col'] as Color).withOpacity(0.3))),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(roadmaps[index]['icon'], color: roadmaps[index]['col']),
              const SizedBox(height: 8),
              Text(roadmaps[index]['name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold))
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceGrid(bool isPremium) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allResources.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85),
      itemBuilder: (context, index) {
        final item = allResources[index];
        return GestureDetector(
          onTap: () => isPremium ? _launchURL(item.url) : _showPremiumModal(),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, color: item.color, size: 24),
                    const Spacer(),
                    Text(item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(item.subTitle,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10)),
                    const SizedBox(height: 12),
                    Container(
                      height: 35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text("LEARN",
                              style: TextStyle(
                                  color: item.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(22)),
                    child: const Icon(Icons.lock_person_rounded,
                        color: Colors.amberAccent, size: 30),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
