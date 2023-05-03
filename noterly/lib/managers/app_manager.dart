import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:noterly/managers/file_manager.dart';
import 'package:noterly/managers/lifecycle_event_handler.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/models/app_data.dart';
import 'package:noterly/models/notification_item.dart';

import 'log.dart';

class AppManager {
  static final AppManager _instance = AppManager._internal();

  static AppManager get instance => _instance;

  AppManager._internal() {
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallback: () async {
          // If we're resuming, we need to reload the data from file in case an item has been deleted from a notification
          // action. In this case, a separate instance of the app will have been launched to handle the action, and the
          // data will have been saved to file. We need to reload the data from file to ensure the UI is up to date.
          Log.logger.d('Resuming app, reloading data from file...');
          await fullUpdate();

          // We also need to update the notifications, to ensure any notifications that need to be displayed are displayed.
          Log.logger.d('Updating notifications...');
          await NotificationManager.instance.updateAllNotifications();
        },
        suspendingCallback: () async => Log.logger.d('App suspended.'),
      ),
    );

    _load();
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 8,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Logger get logger => _logger;

  AppData data = AppData(
    notificationItems: [],
    snoozeDuration: const Duration(hours: 1),
  );

  final notifier = ValueNotifier<List<NotificationItem>>([]);

  List<NotificationItem?> deletedItems = [];

  var isInitialised = false;
  Future? _loadingFuture;

  Future ensureInitialised() async {
    if (isInitialised) {
      return;
    }

    return _loadingFuture;
  }

  Future _load() async {
    _loadingFuture = FileManager.load();
    var newData = await _loadingFuture;

    _loadingFuture = null;

    if (newData == null) {
      Log.logger.d('No previous save found.');
      notifier.value = [];
      newData.notificationItems = [];
      return;
    }

    data = newData!;
    notifier.value = data.notificationItems;
    Log.logger.d('Loaded data from file.');

    isInitialised = true;
  }

  Future<void> _save() async {
    Log.logger.d('Saving data to file...');
    data.notificationItems = notifier.value;

    await FileManager.save(data);
  }

  // #region List management
  NotificationItem itemAt(int i) => notifier.value[i];

  NotificationItem? getItem(String id) {
    var found = notifier.value.where((element) => element.id == id);
    return found.isEmpty ? null : found.first;
  }

  Future addItem(NotificationItem item, {bool deferNotificationManagerCall = false}) async {
    notifier.value.add(item);
    await _save();
    _updateNotifier();

    if (!deferNotificationManagerCall) {
      NotificationManager.instance.showOrUpdateNotification(item);
    }
  }

  Future editItem(NotificationItem item, {bool deferNotificationManagerCall = false}) async {
    var found = notifier.value.where((element) => element.id == item.id);
    if (found.isEmpty) {
      return;
    }

    var index = notifier.value.indexOf(found.first);
    notifier.value[index] = item;
    await _save();
    _updateNotifier();

    if (!deferNotificationManagerCall) {
      NotificationManager.instance.showOrUpdateNotification(item);
    }
  }

  Future deleteItem(String id, {bool deferNotificationManagerCall = false}) async {
    var found = notifier.value.where((element) => element.id == id);
    if (found.isEmpty) {
      return;
    }

    deletedItems = [found.first];
    notifier.value.remove(found.first);

    await _save();
    _updateNotifier();

    if (!deferNotificationManagerCall) {
      await NotificationManager.instance.cancelNotification(id);
    }
  }

  Future deleteAllArchivedItems({bool deferNotificationManagerCall = false}) async {
    var archivedItems = notifier.value.where((element) => element.archived).toList();
    if (archivedItems.isEmpty) {
      return;
    }

    deletedItems = archivedItems;

    for (var element in archivedItems) {
      notifier.value.remove(element);
      if (!deferNotificationManagerCall) {
        await NotificationManager.instance.cancelNotification(element.id);
      }
    }

    await _save();
    _updateNotifier();
  }

  Future archiveItem(String id, {bool deferNotificationManagerCall = false}) async {
    var found = notifier.value.where((element) => element.id == id);
    if (found.isEmpty) {
      return;
    }

    var index = notifier.value.indexOf(found.first);
    notifier.value[index].archived = true;
    notifier.value[index].archivedDateTime = DateTime.now();
    await _save();
    _updateNotifier();

    if (!deferNotificationManagerCall) {
      await NotificationManager.instance.cancelNotification(id);
    }
  }

  Future restoreArchivedItem(String id, {bool deferNotificationManagerCall = false}) async {
    var found = notifier.value.where((element) => element.id == id);
    if (found.isEmpty) {
      return;
    }

    var index = notifier.value.indexOf(found.first);
    notifier.value[index].archived = false;
    notifier.value[index].archivedDateTime = null;
    await _save();
    _updateNotifier();

    if (!deferNotificationManagerCall) {
      NotificationManager.instance.showOrUpdateNotification(notifier.value[index]);
    }
  }

  Future restoreLastDeletedItems({bool deferNotificationManagerCall = false}) async {
    if (deletedItems.isEmpty) {
      return;
    }

    for (var item in deletedItems) {
      await addItem(item!, deferNotificationManagerCall: deferNotificationManagerCall);
    }

    deletedItems = [];
  }

  // #endregion

  Future saveSettings() async {
    Log.logger.d('Saving data for settings...');
    await _save();
    _updateNotifier();
    Log.logger.d('Data saved.');
  }

  Future fullUpdate() async {
    Log.logger.d('Full update requested, reloading data from file...');
    await _load();
    _updateNotifier();
    Log.logger.d('Full update completed.');
    printItems();
  }

  void _updateNotifier() {
    notifier.value = List.from(notifier.value); // Update value notifier
  }

  void printItems() => Log.logger.d(notifier.value);
}
