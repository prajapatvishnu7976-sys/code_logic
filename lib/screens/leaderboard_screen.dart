import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text("HALL OF FAME 🏆",
            style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.indigoAccent));
          }
          var users = snapshot.data!.docs;

          return Column(
            children: [
              _buildTopPodium(users),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: users.length > 3 ? users.length - 3 : 0,
                    itemBuilder: (context, index) {
                      var data =
                          users[index + 3].data() as Map<String, dynamic>;
                      return _buildUserTile(index + 4, data);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopPodium(List<QueryDocumentSnapshot> users) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (users.length > 1)
            _buildPodiumItem(users[1], "2", Colors.grey, 70),
          if (users.isNotEmpty)
            _buildPodiumItem(users[0], "1", Colors.amber, 90),
          if (users.length > 2)
            _buildPodiumItem(users[2], "3", Colors.brown, 70),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
      QueryDocumentSnapshot user, String rank, Color col, double size) {
    var data = user.data() as Map<String, dynamic>;
    return Column(
      children: [
        Text("#$rank",
            style: TextStyle(color: col, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        CircleAvatar(
            radius: size / 2,
            backgroundColor: col,
            child: CircleAvatar(
                radius: (size / 2) - 3,
                backgroundColor: const Color(0xFF0F172A),
                child: Text(data['name'][0],
                    style: const TextStyle(color: Colors.white)))),
        const SizedBox(height: 10),
        Text(data['name'].toString().split(' ')[0],
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        Text("${data['points']} XP",
            style: TextStyle(color: col, fontSize: 10)),
      ],
    );
  }

  Widget _buildUserTile(int rank, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text("#$rank",
              style: const TextStyle(
                  color: Colors.white38, fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          CircleAvatar(
              radius: 15,
              backgroundColor: Colors.indigoAccent,
              child: Text(data['name'][0],
                  style: const TextStyle(fontSize: 12, color: Colors.white))),
          const SizedBox(width: 15),
          Text(data['name'],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text("${data['points']} XP",
              style: const TextStyle(
                  color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
