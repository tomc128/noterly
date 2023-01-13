import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/file_manager.dart';
import 'package:noti_buddy/models/app_data.dart';
import 'package:noti_buddy/models/notification_item.dart';

class AppManager {
  static final AppManager _instance = AppManager._internal();
  static AppManager get instance => _instance;
  AppManager._internal() {
    _load();
  }

  Future ensureInitialised() async {
    if (isInitialised) {
      return;
    }

    return _loadingFuture;
  }

  var isInitialised = false;
  Future? _loadingFuture;

  final notifier = ValueNotifier<List<NotificationItem>>([]);

  Future _load() async {
    _loadingFuture = FileManager.load();
    var data = await _loadingFuture;

    isInitialised = true;
    _loadingFuture = null;

    if (data == null) {
      return;
    }

    notifier.value = data.notificationItems;
  }

  Future<void> _save() async {
    var data = AppData(notificationItems: notifier.value);

    await FileManager.save(data);
  }

  NotificationItem? getItem(String id) {
    var found = notifier.value.where((element) => element.id == id);
    return found.isEmpty ? null : found.first;
  }

  void addItem(NotificationItem item) {
    notifier.value.add(item);
    _updateNotifier();
    _save();
  }

  void editItem(NotificationItem item) {
    var found = notifier.value.where((element) => element.id == item.id);
    if (found.isEmpty) {
      return;
    }

    var index = notifier.value.indexOf(found.first);
    notifier.value[index] = item;
    _updateNotifier();
    _save();
  }

  void deleteItem(String id) {
    notifier.value.removeWhere((element) => element.id == id);
    _updateNotifier();
    _save();
  }

  NotificationItem itemAt(int i) => notifier.value[i];

  void _updateNotifier() {
    notifier.value = List.from(notifier.value); // Update value notifier
  }

  void printItems() {
    var output = '';
    for (var element in notifier.value) {
      output += '$element, ';
    }
    print('[$output]');
  }
}
