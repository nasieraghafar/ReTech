import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Create an instance of the FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification settings for both Android and iOS
  Future<void> initNotification() async {
    print("Initializing notifications");

    // Define Android-specific initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Define iOS-specific initialization settings, requesting permissions for alerts, badges, and sounds
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true, // Request permission to show alerts
      requestBadgePermission: true, // Request permission to update app badge
      requestSoundPermission: true, // Request permission to play sounds
    );

    // Combine Android and iOS initialization settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid, // Set Android settings
      iOS: initializationSettingsIOS, // Set iOS settings
    );

    // Initialize the notifications plugin with the settings and a callback for handling notification responses
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle the notification response when the user interacts with the notification
        print("Notification received: ${notificationResponse.payload}");
        // Can add custom logic here to handle different types of notifications or payloads
      },
    );

    print("Notifications initialized");

    // Define a notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channelId', // Unique identifier for the channel
      'channelName', // Name of the channel
      importance: Importance.max, // Importance level for the notifications
    );

    // Create the notification channel on Android
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  // Define the details for the notification (e.g., appearance, priority)
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId', // Channel ID to match with the notification channel created
        'channelName', // Channel name to match with the notification channel created
        importance: Importance.max, // Set the importance of the notification
        priority: Priority.high, // Set the priority of the notification
        icon: '@mipmap/ic_launcher', // Use a default icon for testing
      ),
      iOS: DarwinNotificationDetails(), // iOS-specific notification details
    );
  }

  // Show a notification with the provided details
  Future<void> showNotification({
    int id = 0, // Unique ID for the notification
    String? title, // Title of the notification
    String? body, // Body text of the notification
    String? payLoad, // Optional payload to pass with the notification
  }) async {
    print("Showing notification: $title, $body");
    // Display the notification with the specified ID, title, body, and payload
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(), // Use the notification details defined earlier
      payload: payLoad, // Attach the payload to the notification
    );
    print("Notification shown");
  }

  // Schedule a notification to be shown at a specific time
  Future<void> scheduleNotification({
    int id = 0, // Unique ID for the notification
    String? title, // Title of the notification
    String? body, // Body text of the notification
    String? payLoad, // Optional payload to pass with the notification
    required DateTime scheduledNotificationDateTime, // Date and time when the notification should be shown
  }) async {
    // Check for SCHEDULE_EXACT_ALARM permission
    if (await Permission.scheduleExactAlarm.request().isGranted) {
      // Permission granted, schedule the notification
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local), // Convert DateTime to TZDateTime
        notificationDetails(), // Use the notification details defined earlier
        androidAllowWhileIdle: true, // Allow notifications while the device is idle
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime, // Treat the scheduled time as an absolute time
      );
    } else {
      print("Exact alarm permission not granted.");
      // Handle the case where permission is not granted, e.g., show a message to the user
    }
  }
}
