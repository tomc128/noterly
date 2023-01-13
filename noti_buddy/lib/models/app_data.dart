import 'package:noti_buddy/models/notification_item.dart';

class AppData {
  List<NotificationItem> notificationItems;

  AppData({
    required this.notificationItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationItems': notificationItems.map((e) => e.toJson()).toList(),
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      notificationItems: (json['notificationItems'] as List<dynamic>)
          .map((e) => NotificationItem.fromJson(e))
          .toList(),
    );
  }
}
