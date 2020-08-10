import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show File, Platform;

class NotificationPlugin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin;
  InitializationSettings initializationSettings;

  NotificationPlugin() {
    init();
  }

  init() async {
    flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      print('ios');
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    AndroidInitializationSettings initializationSettingAndroid =
    AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingIOS =
    IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingAndroid, initializationSettingIOS);
  }

  _requestIOSPermission() {
    flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          onNotificationClick(payload);
        });
  }

  Future<void> showNotification(String title,String body) async {
    AndroidNotificationDetails androidChannelSpecifics =
    AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      ticker: 'test',
      importance: Importance.Max,
      priority: Priority.High,
      groupKey: '1',

    );

    IOSNotificationDetails iosChannelSpecifics = IOSNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await flutterLocalNotificationPlugin.show(
        int.parse(DateTime.now().toIso8601String().split(':')[2].split('.')[0]),
        title,
        body,
        platformChannelSpecifics,
        payload: 'Test payload');
  }
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  print(title);
}
