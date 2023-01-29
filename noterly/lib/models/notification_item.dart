import 'package:flutter/material.dart';
import 'package:noterly/models/repetition_data.dart';

class NotificationItem {
  String id;

  String title;
  String? body;

  Color colour;

  DateTime? dateTime;
  // Duration? repeatDuration;
  RepetitionData? repetitionData;

  bool get isRepeating => repetitionData != null;

  bool archived;
  DateTime? archivedDateTime;

  NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.dateTime,
    this.repetitionData,
    required this.colour,
    this.archived = false,
    this.archivedDateTime,
  });

  @override
  String toString() {
    return 'NotificationItem(id: $id, title: $title, body: $body, dateTime: $dateTime, repetitionData: $repetitionData, colour: $colour, archived: $archived)';
  }

  Duration get nextRepeatDuration {
    if (repetitionData == null) {
      return Duration.zero;
    }

    final now = DateTime.now();
    final lastSent = dateTime ?? now;

    // Return the duration between now and the next time the notification should be sent

    switch (repetitionData!.type) {
      case Repetition.hourly:
        return Duration(hours: repetitionData!.number) - (now.difference(lastSent));
      case Repetition.daily:
        return Duration(days: repetitionData!.number) - (now.difference(lastSent));
      case Repetition.weekly:
        return Duration(days: repetitionData!.number * 7) - (now.difference(lastSent));
      case Repetition.monthly:
        var nextMonth = DateTime(lastSent.year, lastSent.month + repetitionData!.number, lastSent.day);
        return nextMonth.difference(now);
      case Repetition.yearly:
        var nextYear = DateTime(lastSent.year + repetitionData!.number, lastSent.month, lastSent.day);
        return nextYear.difference(now);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'dateTime': dateTime?.toIso8601String(),
        'repetitionData': repetitionData?.toJson(),
        'colour': colour.value,
        'archived': archived,
        'archivedDateTime': archivedDateTime?.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
        repetitionData: RepetitionData.fromJson(json['repetitionData']),
        colour: Color(json['colour']),
        archived: json['archived'] ?? false,
        archivedDateTime: json['archivedDateTime'] != null ? DateTime.parse(json['archivedDateTime']) : null,
      );
}
