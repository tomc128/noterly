import 'package:noti_buddy/managers/file_manager.dart';
import 'package:noti_buddy/models/notification_item.dart';

class AppData {
  static AppData? _instance;
  static Future<AppData> get instance async {
    _instance ??= await FileManager.load() ??
        AppData(
          notificationItems: [],
        );

    return _instance!;
  }

  List<NotificationItem> notificationItems;

  AppData({
    required this.notificationItems,
  });

  Future<void> save() async {
    await FileManager.save(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationItems':
          notificationItems.map((item) => item.toJson()).toList(),
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      notificationItems: List<NotificationItem>.from(
        json['notificationItems'].map(
          (item) => NotificationItem.fromJson(item),
        ),
      ),
    );
  }
}
