import 'package:ancilmedia/Env_File.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firebase_options.dart';
import 'view/Homepage.dart';

// 🔔 Local Notification Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// 🔧 Android Channel
const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
  'default', // ✅ Must match backend channelId
  'Default Notifications',
  description: 'General app notifications',
  importance: Importance.high,
);

// 🔕 Background Message Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showFlutterNotification(message);
  print("🔕 [Background] Message: ${message.messageId}");
}

// 🔔 Show Local Notification
void _showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: android != null
            ? AndroidNotificationDetails(
          defaultChannel.id,
          defaultChannel.name,
          channelDescription: defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        )
            : null,
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}

// ✅ Initialize Local Notification Settings
Future<void> _initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings, // ✅ Added for iOS
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;

    // 🟡 Request Notification Permission
    messaging.requestPermission();

    // 📱 Get FCM Token
    messaging.getToken().then((token) async {
      print('📱 FCM Token: $token');

      try {
        final response = await http.post(
          Uri.parse('${baseUrl}/api/register-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': token}),
        );

        print('✅ Token registered: ${response.statusCode}');
      } catch (e) {
        print('❌ Failed to register token: $e');
      }
    });

    // 🔔 Foreground Notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground message: ${message.notification?.title}');
      _showFlutterNotification(message);
    });

    // 📲 Notification Tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Notification tapped: ${message.notification?.title}');
      // TODO: Navigate based on message.data or notification content
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
