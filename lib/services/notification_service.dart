import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ✅ Sabse pehle init() ko sahi karte hain
  Future<void> init() async {
    // 1. Permission maango (iOS/Android 13+)
    await _messaging.requestPermission();

    // 2. Android setting (Notification Bar ke liye)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings);

    // 3. Background/Terminated state ke liye topic subscribe karo
    // Isse saare users ko ek saath message jayega
    await _messaging.subscribeToTopic('all_users');

    // 4. Foreground mein message aane par kya karein
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  // ✅ Ye function upar notification bar mein message dikhayega
  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'smart_prep_channel', // ID
          'SmartPrep Notifications', // Name
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    _localNotifications.show(
      0,
      message.notification?.title ?? "New Update",
      message.notification?.body ?? "Check out SmartPrep Pro!",
      platformDetails,
    );
  }

  // ✅ Purana listener (Optional: agar dialog bhi chahiye ho toh rakho, nahi toh hata do)
  void listenToNotifications(dynamic context) {
    // Ab iski zaroorat nahi kyunki humne upar init mein onMessage laga diya hai
  }
}
