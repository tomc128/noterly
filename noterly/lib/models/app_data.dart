import 'package:noterly/models/notification_item.dart';

class AppData {
  List<NotificationItem> notificationItems;

  Duration snoozeDuration = const Duration(hours: 1);

  AppData({
    required this.notificationItems,
    required this.snoozeDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationItems': notificationItems.map((e) => e.toJson()).toList(),
      'snoozeDuration': snoozeDuration.inSeconds,
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      notificationItems: (json['notificationItems'] as List<dynamic>).map((e) => NotificationItem.fromJson(e)).toList(),
      snoozeDuration: json['snoozeDuration'] != null ? Duration(seconds: json['snoozeDuration']) : const Duration(hours: 1),
    );
  }
}
