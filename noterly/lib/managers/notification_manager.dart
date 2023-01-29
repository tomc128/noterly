import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/isolate_manager.dart';
import 'package:noterly/managers/log.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../build_info.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  static NotificationManager get instance => _instance;
  NotificationManager._internal() {
    init();
  }

  final _plugin = FlutterLocalNotificationsPlugin();

  void init() async {
    Log.logger.d('Initialising notification manager...');

    tz.initializeTimeZones();

    const initializationSettingsAndroid = AndroidInitializationSettings('notification_icon_48');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
  }

  static Future handleResponse(NotificationResponse response, {bool isBackground = false}) async {
    Log.logger.d('Handling notification response. ${isBackground ? 'Background' : 'Foreground'} mode. Action: "${response.actionId}". Payload: "${response.payload}"');

    var itemId = response.payload;
    if (itemId == null) {
      Log.logger.d('No payload, ignoring');
      return;
    }

    if (isBackground) {
      await AppManager.instance.ensureInitialised();
    }

    var item = AppManager.instance.getItem(itemId);
    if (item == null) {
      Log.logger.d('No item found for payload, requesting a full update and retrying...');
      await AppManager.instance.fullUpdate();
      item = AppManager.instance.getItem(itemId);
      if (item == null) {
        Log.logger.d('Still no item found for payload, ignoring');
        return;
      }
    }

    await Firebase.initializeApp(); // Remove options to use native manual installation of Firebase, as Dart-only isn't working yet for some reason
    await FirebaseAnalytics.instance.setDefaultEventParameters({'version': BuildInfo.appVersion});

    if (response.actionId == 'done') {
      if (item.isRepeating) {
        Log.logger.d('Snoozing notification "${item.title}"');
        await NotificationManager.instance.updateRepeatingNotification(item);
        await FirebaseAnalytics.instance.logEvent(name: 'mark_repeating_notification_done');
      } else {
        Log.logger.d('Archiving notification "${item.title}"');
        await AppManager.instance.archiveItem(item.id, deferNotificationManagerCall: true);
        await FirebaseAnalytics.instance.logEvent(name: 'mark_notification_done');
      }

      // If we're in the background, we need to send a message to the main isolate to update the UI
      if (isBackground) {
        var sendPort = IsolateNameServer.lookupPortByName(IsolateManager.mainPortName);
        sendPort?.send('update');
        if (sendPort == null) {
          Log.logger.e('Failed to send message to main isolate (port not found).');
        }
      }

      return;
    }

    if (!isBackground) {
      // TODO: Open the item
      Log.logger.d('Opening notification "${item.title}"');
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
        Log.logger.d('Got A13 permission result: $result');
      }
    } catch (e) {
      Log.logger.e('Failed to request A13 notification permission, $e');
    }
  }

  Future _cancelAllNotifications() async => await _plugin.cancelAll();

  Future cancelNotification(String itemId) async => await _plugin.cancel(itemId.hashCode);

  Future<bool> _notificationIsShown(NotificationItem item) async {
    var notifications = await _plugin.getActiveNotifications();
    return notifications.any((n) => n.id == item.id.hashCode);
  }

  Future updateAllNotifications() async {
    for (var item in AppManager.instance.notifier.value) {
      if (item.archived) continue;

      if (item.isRepeating) {
        await updateRepeatingNotification(item);
      } else {
        await updateNotification(item);
      }
    }
  }

  Future forceUpdateAllNotifications() async {
    await _cancelAllNotifications(); // Cancel all existing notifications; faster than checking each one

    for (var item in AppManager.instance.notifier.value) {
      if (item.archived) continue;

      if (item.isRepeating) {
        await updateRepeatingNotification(item); // Need to do some calculations before, so call update instead of show/schedule
      } else {
        await _showOrScheduleNotification(item);
      }
    }
  }

  Future updateNotification(NotificationItem item) async {
    if (await _notificationIsShown(item)) {
      return; // Notification is already shown, no need to show another
    }

    if (item.archived) return;
    await _showOrScheduleNotification(item);
  }

  Future forceUpdateNotification(NotificationItem item) async {
    // Cancel the existing notification, if any
    await _plugin.cancel(item.id.hashCode);

    if (item.archived) return;
    await _showOrScheduleNotification(item);
  }

  Future updateAllRepeatingNotifications() async {
    for (var item in AppManager.instance.notifier.value) {
      if (item.archived) continue;
      if (!item.isRepeating) continue;

      await updateRepeatingNotification(item);
    }
  }

  Future updateRepeatingNotification(NotificationItem item) async {
    if (item.archived) return;
    if (!item.isRepeating) return;

    var isShown = await _notificationIsShown(item);
    var now = DateTime.now();

    if (item.dateTime != null) {
      if (isShown) {
        // Notification is already shown, don't update it (until the user marks it as done)
        Log.logger.d('Repeating & scheduled notification "${item.title}" is already shown, no need to update');
        return;
      }

      Log.logger.d('Repeating & scheduled notification "${item.title}" needs to be updated');

      // Repeat duration has passed, update the dateTime and schedule the notification
      // calculate next time as dateTime + repeatDuration as many times as needed to get to the future
      while (item.dateTime!.isBefore(now)) {
        item.dateTime = item.dateTime!.add(item.nextRepeatDuration);
      }
      await AppManager.instance.editItem(item, deferNotificationManagerCall: true);
      await _scheduleNotification(item);
    } else {
      // Since this notification has no dateTime, we'll just show it immediately and set the dateTime to now + repeatDuration
      // Which will mean this notification is shown again in repeatDuration seconds
      item.dateTime = now.add(item.nextRepeatDuration);
      await AppManager.instance.editItem(item, deferNotificationManagerCall: true);

      if (isShown) {
        Log.logger.d('Repeating & unscheduled notification "${item.title}" is already shown, no need to update');
        return;
      }

      Log.logger.d('Repeating & unscheduled notification "${item.title}" needs to be updated');
      await _scheduleNotification(item);
    }
  }

  Future _showOrScheduleNotification(NotificationItem item) async {
    if (item.dateTime == null) {
      await _showNotification(item);
    } else {
      await _scheduleNotification(item);
    }
  }

  Future _showNotification(NotificationItem item, {bool ignoreDateTime = false}) async {
    if (!ignoreDateTime) {
      assert(
        item.dateTime == null,
        'Notification must not have a dateTime in order to be shown immediately.',
      );
    }

    var androidDetails = _getNotificationDetails(item);
    var details = NotificationDetails(android: androidDetails);

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

    if (item.dateTime!.isBefore(DateTime.now())) {
      // Show notification immediately if it's in the past
      await _showNotification(item, ignoreDateTime: true);
      return;
    }

    var androidDetails = _getNotificationDetails(item);
    var details = NotificationDetails(android: androidDetails);

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

  AndroidNotificationDetails _getNotificationDetails(NotificationItem item) => AndroidNotificationDetails(
        item.dateTime == null ? 'immediate_notifications' : 'scheduled_notifications',
        item.dateTime == null ? 'Immediate notifications' : 'Scheduled notifications',
        channelDescription: item.dateTime == null ? 'Notifications that are shown immediately' : 'Notifications that are scheduled for a future time',
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'done',
            'Mark as done',
          ),
        ],
        category: AndroidNotificationCategory.reminder,
        importance: Importance.max,
        priority: Priority.max,
        groupKey: 'uk.co.tdsstudios.noterly.ALL_NOTIFICATIONS_GROUP',
        color: item.colour,
        ongoing: true,
        when: item.dateTime == null ? null : item.dateTime!.millisecondsSinceEpoch,
      );
}
