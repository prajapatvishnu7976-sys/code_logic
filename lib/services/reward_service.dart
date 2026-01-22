import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardService {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<int?> checkDailyReward() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
    DocumentSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) return null;

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    Timestamp? lastCheckIn = data['lastCheckIn'];
    int points = data['points'] ?? 0;

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (lastCheckIn == null || lastCheckIn.toDate().isBefore(today)) {
      int bonus = 20;
      await userRef.update({'points': points + bonus, 'lastCheckIn': today});
      return bonus;
    }
    return null;
  }
}
