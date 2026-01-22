import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle({String? referralCode}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!, referralCode);
      }

      return userCredential;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future<void> _saveUserToFirestore(User user, String? referralCode) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      // 🎁 Referral Logic: Agar naya user kisi ke code se aaya hai
      if (referralCode != null &&
          referralCode.isNotEmpty &&
          referralCode != user.uid) {
        await _rewardReferrer(referralCode);
      }

      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? "Smart Student",
        'profile_pic': user.photoURL ?? "",
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'student',
        'points': referralCode != null
            ? 50
            : 0, // Naye user ko 50 XP bonus agar referral se aaya
        'referredBy': referralCode,
        'isPremium': false,
      });
    } else {
      await userRef.update({'lastLogin': FieldValue.serverTimestamp()});
    }
  }

  // Jisne invite kiya use 100 XP do
  Future<void> _rewardReferrer(String referrerId) async {
    try {
      await _firestore.collection('users').doc(referrerId).update({
        'points': FieldValue.increment(100),
      });
    } catch (e) {
      print("Referral Reward Error: $e");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
