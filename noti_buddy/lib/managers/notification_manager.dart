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

  void init() async {
    tz.initializeTimeZones();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _plugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onResponse,
        onDidReceiveBackgroundNotificationResponse: onBackgroundResponse);
  }

  static Future onResponse(NotificationResponse response) async {
    print('Got notification response: $response');

    var itemId = response.payload;
    if (itemId == null) {
      print('No payload, ignoring');
      return;
    }

    var item = AppManager.instance.getItem(itemId);
    if (item == null) {
      print('No item found for payload, ignoring');
      return;
    }

    if (response.actionId == 'done') {
      print('Removing notification "${item.title}" [foreground]');
      AppManager.instance.deleteItem(itemId);
      return;
    }

    print('Opening notification "${item.title}"');
  }

  @pragma('vm:entry-point')
  static Future onBackgroundResponse(NotificationResponse response) async {
    var itemId = response.payload;
    if (itemId == null) {
      return;
    }

    await AppManager.instance.ensureInitialised();

    var item = AppManager.instance.getItem(itemId);
    if (item == null) {
      print('Notification with id "$itemId" not found');
      return;
    }

    if (response.actionId == 'done') {
      print('Removing notification "${item.title}" [background]');
      AppManager.instance.deleteItem(itemId);
      return;
    }
  }

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future requestAndroid13Permissions() async {
    try {
      var android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: item.id,
    );
  }
}
