import 'package:noterly/models/notification_item.dart';

class AppData {
  List<NotificationItem> notificationItems;

  Duration snoozeDuration;
  String snoozeToastText;

  AppData({
    required this.notificationItems,
    required this.snoozeDuration,
    required this.snoozeToastText,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationItems': notificationItems.map((e) => e.toJson()).toList(),
      'snoozeDuration': snoozeDuration.inSeconds,
      'snoozeToastText': snoozeToastText,
    };
  }

  factory AppData.defaults() => AppData.fromJson({});

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        notificationItems: AppDataJsonParser<List<NotificationItem>>('notificationItems', [], parser: (value) => (value as List).map((item) => NotificationItem.fromJson(item)).toList()).parse(json),
        snoozeDuration: AppDataJsonParser<Duration>('snoozeDuration', const Duration(hours: 1), parser: (value) => Duration(seconds: value)).parse(json),
        snoozeToastText: AppDataJsonParser<String>('snoozeToastText', 'Notification snoozed').parse(json),
      );
}

class AppDataJsonParser<T> {
  final String key;
  final T defaultValue;
  final T Function(dynamic)? parser;

  AppDataJsonParser(this.key, this.defaultValue, {this.parser});

  T parse(Map<String, dynamic> json) {
    if (!json.containsKey(key)) return defaultValue;
    if (parser != null) return parser!(json[key]);
    return json[key];
  }
}
