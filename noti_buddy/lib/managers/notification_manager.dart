import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  static NotificationManager get instance => _instance;
  NotificationManager._internal() {
    init();
  }

  final _plugin = FlutterLocalNotificationsPlugin();

  final mainRecievePort = ReceivePort();

  void init() async {
    tz.initializeTimeZones();

    // Register the port with the main isolate
    var registerResult = IsolateNameServer.registerPortWithName(mainRecievePort.sendPort, 'main');
    if (!registerResult) {
      IsolateNameServer.removePortNameMapping('main');
      registerResult = IsolateNameServer.registerPortWithName(mainRecievePort.sendPort, 'main');

      if (!registerResult) {
        throw Exception('Failed to register port with main isolate (x2)');
      }
    }

    // Listen for messages from the background isolate
    mainRecievePort.listen((message) {
      if (message == 'update') {
        print('Forcing a full update...');
        AppManager.instance.fullUpdate();
      } else {
        print('Unknown message from background isolate: "$message"');
      }
    });

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
  }

  static Future handleResponse(NotificationResponse response, {bool isBackground = false}) async {
    print('Handling notification response. ${isBackground ? 'Background' : 'Foreground'} mode. Action: "${response.actionId}". Payload: "${response.payload}"');

    var itemId = response.payload;
    if (itemId == null) {
      print('No payload, ignoring');
      return;
    }

    if (isBackground) {
      await AppManager.instance.ensureInitialised();
    }

    var item = AppManager.instance.getItem(itemId);
    if (item == null) {
      print('No item found for payload, ignoring');
      return;
    }

    if (response.actionId == 'done') {
      print('Removing notification "${item.title}"');
      AppManager.instance.deleteItem(itemId);

      // If we're in the background, we need to send a message to the main isolate to update the UI
      if (isBackground) {
        var sendPort = IsolateNameServer.lookupPortByName('main');
        sendPort?.send('update');
      }

      return;
    }

    if (!isBackground) {
      print('Opening notification "${item.title}"');
    }
  }

  static Future onResponse(NotificationResponse response) async => handleResponse(response, isBackground: false);

  @pragma('vm:entry-point')
  static Future onBackgroundResponse(NotificationResponse response) async => handleResponse(response, isBackground: true);

  Future requestAndroid13Permissions() async {
    try {
      var android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        var result = await android.requestPermission();
        print('Got A13 permission result: $result');
      }
    } catch (e) {
      print('Failed to request A13 notification permission, $e');
    }
  }

  void _cancelAllNotifications() {
    _plugin.cancelAll();
  }

  void updateAllNotifications() {
    _cancelAllNotifications();

    for (var item in AppManager.instance.notifier.value) {
      if (item.dateTime == null) {
        _showNotification(item);
      } else {
        _scheduleNotification(item);
      }
    }
  }

  Future _showNotification(NotificationItem item) async {
    assert(
      item.dateTime == null,
      'Notification must not have a dateTime in order to be shown immediately.',
    );

    const androidDetails = AndroidNotificationDetails(
      'test_channel_id',
      'test_channel_name',
      channelDescription: 'channel_description',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'done',
          'Mark as done',
        ),
      ],
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      item.id.hashCode,
      item.title,
      item.body,
      details,
      payload: item.id,
    );
  }

  Future _scheduleNotification(NotificationItem item) async {
    assert(
      item.dateTime != null,
      'Notification must have a dateTime in order to be scheduled.',
    );

    const androidDetails = AndroidNotificationDetails(
      'test_channel_id',
      'test_channel_name',
      channelDescription: 'channel_description',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'done',
          'Mark as done',
        ),
      ],
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      item.id.hashCode,
      item.title,
      item.body,
      tz.TZDateTime.from(item.dateTime!, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: item.id,
    );
  }
}
