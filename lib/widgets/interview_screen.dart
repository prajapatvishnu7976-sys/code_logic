import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  // 🔥 Premium Interview Links (YouTube Video Links)
  final List<Map<String, dynamic>> experiences = const [
    {
      "company": "Google",
      "role": "Software Engineer (L3)",
      "candidate": "Striver",
      "color": Colors.red,
      "link": "https://www.youtube.com/watch?v=cGjSOVz-mYg", // Example Link
    },
    {
      "company": "Amazon",
      "role": "SDE-1 (Off-Campus)",
      "candidate": "Love Babbar",
      "color": Colors.orange,
      "link": "https://www.youtube.com/watch?v=8M20Ly-d1hM",
    },
    {
      "company": "Microsoft",
      "role": "SDE Intern",
      "candidate": "Arsh Goyal",
      "color": Colors.blue,
      "link": "https://www.youtube.com/watch?v=F3a5YwLg5eY",
    },
    {
      "company": "Atlassian",
      "role": "PPO Experience",
      "candidate": "Anuj Bhaiya",
      "color": Colors.indigo,
      "link": "https://www.youtube.com/watch?v=IcO_kH0NqMc",
    },
    {
      "company": "Flipkart",
      "role": "SDE-1 Interview",
      "candidate": "Keerti Purswani",
      "color": Colors.yellow,
      "link": "https://www.youtube.com/watch?v=YpL_XwWzFh8",
    },
    {
      "company": "Goldman Sachs",
      "role": "Summer Analyst",
      "candidate": "Kushagra",
      "color": Colors.cyan,
      "link": "https://www.youtube.com/watch?v=3u1d9b4f9w8",
    },
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Interview Archive 💎",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Premium Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.amber,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You have exclusive access to these premium interview breakdowns.",
                    style: TextStyle(
                      color: Colors.brown[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Video List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                final exp = experiences[index];
                return GestureDetector(
                  onTap: () => _launchURL(exp['link']),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Thumbnail Placeholder with Play Icon
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: exp['color'],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                exp['color'].withOpacity(0.8),
                                exp['color'],
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: exp['color'],
                                size: 40,
                              ),
                            ),
                          ),
                        ),

                        // 2. Details
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    exp['company'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Text(
                                      "Verified",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                exp['role'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "By ${exp['candidate']}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
