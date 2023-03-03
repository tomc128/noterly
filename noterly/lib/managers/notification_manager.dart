import 'dart:convert';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noterly/main.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/isolate_manager.dart';
import 'package:noterly/managers/log.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/pages/edit_notification_page.dart';
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

    if (response.payload == null) {
      Log.logger.d('No payload, ignoring');
      return;
    }

    if (isBackground) {
      await AppManager.instance.ensureInitialised();
    }

    // The old notification system used the item ID as the payload, but the new system uses a JSON string
    // containing the item JSON. For backwards compatibility, we need to check if the payload is a JSON string
    // and if so, extract the item ID from it.
    String itemId;

    try {
      var decoded = jsonDecode(response.payload!);
      itemId = NotificationItem.fromJson(decoded).id;
    } on FormatException catch (_) {
      Log.logger.d('Payload is not a JSON string, assuming it is an item ID');
      itemId = response.payload!;
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
        Log.logger.d('Marking repeating notification "${item.title}" as done and rescheduling');
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

    if (response.actionId == 'snooze') {
      Log.logger.d('Snoozing notification "${item.title}"');
      await _instance.cancelNotification(item.id);
      await _instance._scheduleSnoozedNotification(item);
      Fluttertoast.showToast(
        msg: 'Notification snoozed for 1 hour',
        toastLength: Toast.LENGTH_SHORT,
      );
      await FirebaseAnalytics.instance.logEvent(name: 'snooze_notification');
      return;
    }

    if (!isBackground) {
      MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => EditNotificationPage(item: item!)),
        (route) => route.isFirst,
      );
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

  Future cancelNotification(String itemId) async => await _plugin.cancel(itemId.hashCode);

  Future<bool> _notificationIsShown(NotificationItem item) async {
    var notifications = await _plugin.getActiveNotifications();
    return notifications.any((n) => n.id == item.id.hashCode);
  }

  /// Force updates all notifications. This should only be used where necessary as every notification is cancelled and recreated.
  Future forceUpdateAllNotifications() async {
    for (var item in AppManager.instance.notifier.value) {
      if (item.archived) continue;

      if (item.isRepeating) {
        await updateRepeatingNotification(item);
      } else {
        await showOrUpdateNotification(item);
      }
    }
  }

  Future updateAllNotifications() async {
    var notifications = await _plugin.getActiveNotifications();
    var shownIds = notifications.map((n) => n.id).toList();

    for (var item in AppManager.instance.notifier.value) {
      if (shownIds.contains(item.id.hashCode)) {
        // Notification is already shown. We don't need to do anything, as the notification will be updated when the item is updated.
        // This is either done when editing a notification, or when force updating all notifications.
        continue;
      }

      if (item.archived) continue;

      if (item.isRepeating) {
        await updateRepeatingNotification(item);
      } else {
        await showOrUpdateNotification(item);
      }
    }
  }

  /// Updates a single notification. If the notification is already shown, it is cancelled.
  Future showOrUpdateNotification(NotificationItem item) async {
    if (item.archived) return;

    if (await _notificationIsShown(item)) await cancelNotification(item.id);

    await _showOrScheduleNotification(item);
  }

  /// Updates a repeating notification. This consists of updating its datetime to the next time it should be shown, and then showing it.
  Future updateRepeatingNotification(NotificationItem item) async {
    if (item.archived) return;
    if (!item.isRepeating) return;

    var isShown = await _notificationIsShown(item);
    var now = DateTime.now();

    bool dirty = false;

    if (item.dateTime == null) {
      // For some reason, the notification has no dateTime, so set it to now
      Log.logger.d('Repeating notification "${item.title}" has no dateTime, setting it to now');
      item.dateTime = now;
      dirty = true;
    }

    if (isShown) {
      Log.logger.d('Repeating notification "${item.title}" is already shown, no need to update');
      if (dirty) await AppManager.instance.editItem(item, deferNotificationManagerCall: true);
      return;
    }

    while (item.dateTime!.isBefore(now)) {
      item.dateTime = item.nextRepeatDateTime; // Increment the dateTime until it's in the future
    }

    await AppManager.instance.editItem(item, deferNotificationManagerCall: true);
    await _scheduleNotification(item);
  }

  Future _scheduleSnoozedNotification(NotificationItem item) async {
    // 1h from now
    // TODO: make this configurable

    var now = DateTime.now();
    var snoozeDateTime = now.add(const Duration(hours: 1));

    var androidDetails = _getNotificationDetails(item);
    var details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      item.id.hashCode,
      item.title,
      item.body,
      tz.TZDateTime.from(snoozeDateTime, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode(item),
    );
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
      payload: jsonEncode(item),
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
      payload: jsonEncode(item),
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
          const AndroidNotificationAction(
            'snooze',
            'Snooze',
          ),
        ],
        category: AndroidNotificationCategory.reminder,
        importance: Importance.max,
        priority: Priority.max,
        groupKey: 'uk.co.tdsstudios.noterly.ALL_NOTIFICATIONS_GROUP',
        color: item.colour,
        ongoing: true,
        when: item.dateTime == null ? null : item.dateTime!.millisecondsSinceEpoch,
        autoCancel: false,
      );
}
