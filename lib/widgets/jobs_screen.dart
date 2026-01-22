import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  // 🔥 Apply Link Open Karne Ka Logic
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Navy Background
      appBar: AppBar(
        title: Text(
          "LATEST JOBS 💼",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('postedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.indigoAccent));
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_rounded,
                      size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 15),
                  Text(
                    "No Jobs Posted Yet!",
                    style: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          var jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            physics: const BouncingScrollPhysics(),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              var job = jobs[index].data() as Map<String, dynamic>;

              String role = job['role'] ?? 'Unknown Role';
              String company = job['company'] ?? 'Unknown Company';
              String salary = job['salary'] ?? 'Not Disclosed';
              String desc = job['description'] ?? '';
              String link = job['applyLink'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              role,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ✅ Fixed: Removed emeraldAccent and used greenAccent
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.3)),
                            ),
                            child: Text(
                              salary,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.apartment_rounded,
                              size: 16, color: Colors.white38),
                          const SizedBox(width: 6),
                          Text(
                            company,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Divider(color: Colors.white10, thickness: 1),
                      ),
                      if (desc.isNotEmpty) ...[
                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: Colors.white54, fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchURL(link),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 20),
                          label: const Text("APPLY NOW",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
