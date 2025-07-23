import 'dart:convert';
import 'dart:io';
import 'package:ancilmedia/view/Login_page.dart';
import 'package:ancilmedia/view/Register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'view/Homepage.dart';
import 'package:ancilmedia/Env_File.dart'; // Your backend baseUrl

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
  'default',
  'Default Notifications',
  description: 'General app notifications',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showFlutterNotification(message);
  print("🔕 [Background] Message: ${message.messageId}");
}

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

Future<void> _initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initLocalNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Check login state before runApp
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('✅ Notification permission granted.');

      if (Platform.isIOS) {
        String? apnsToken;
        while (apnsToken == null) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        print('📲 APNs Token: $apnsToken');
      }

      String? fcmToken = await messaging.getToken();
      print('📱 FCM Token: $fcmToken');

      if (fcmToken != null && fcmToken.isNotEmpty) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/api/register-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': fcmToken}),
          );

          print('✅ Token registered: ${response.statusCode}');
          print('📡 Response: ${response.body}');
        } catch (e) {
          print('❌ Failed to register token: $e');
        }
      } else {
        print('❌ FCM Token is null or empty');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 Foreground message: ${message.notification?.title}');
        _showFlutterNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📲 Notification tapped: ${message.notification?.title}');
      });
    } else {
      print('❌ Notifications not authorized');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: widget.isLoggedIn ?  Homepage() : const LoginPage(),
    );
  }
}
