import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _streakKey = 'currentStreak';
  static const String _dateKey = 'lastDate';

  Future<int> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();

    // 🔥 FIX 1: Date ko sahi format (YYYY-MM-DD) mein convert karna
    // Taaki 2026-1-7 ki jagah 2026-01-07 bane
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final currentStreak = prefs.getInt(_streakKey) ?? 0;
    final lastDateStr = prefs.getString(_dateKey);

    // Agar aaj already khol chuka hai
    if (lastDateStr == todayStr) {
      return currentStreak;
    }

    if (lastDateStr != null) {
      try {
        // 🔥 FIX 2: Try-Catch Block
        // Agar purana date format galat hua (jaise abhi hai), toh app crash nahi hoga, reset ho jayega.
        final lastDate = DateTime.parse(lastDateStr);
        final difference = today.difference(lastDate).inDays;

        if (difference == 1) {
          // Kal aaya tha -> Streak Badhao (+1)
          final newStreak = currentStreak + 1;
          await prefs.setInt(_streakKey, newStreak);
          await prefs.setString(_dateKey, todayStr);
          return newStreak;
        } else {
          // Ek din miss ho gaya -> Streak Reset to 1
          await prefs.setInt(_streakKey, 1);
          await prefs.setString(_dateKey, todayStr);
          return 1;
        }
      } catch (e) {
        // Agar koi purana error date mile, toh crash mat hone do, naye sire se shuru karo
        await prefs.setInt(_streakKey, 1);
        await prefs.setString(_dateKey, todayStr);
        return 1;
      }
    }

    // Pehli baar app khola hai
    await prefs.setInt(_streakKey, 1);
    await prefs.setString(_dateKey, todayStr);
    return 1;
  }

  // Sirf streak dekhne ke liye function
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }
}
