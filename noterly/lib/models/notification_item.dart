import 'package:flutter/material.dart';
import 'package:noterly/models/repetition_data.dart';

class NotificationItem {
  String id;

  String title;
  String body;

  Color colour;

  DateTime? dateTime;
  RepetitionData? repetitionData;

  bool archived;
  DateTime? archivedDateTime;

  DateTime? snoozeDateTime;

  bool get isImmediate => dateTime == null;

  bool get isScheduled => dateTime != null;

  bool get isRepeating => repetitionData != null;

  bool get isNotRepeating => repetitionData == null;

  bool get isSnoozed => snoozeDateTime != null;

  bool get isNotSnoozed => snoozeDateTime == null;

  bool get isSnoozedPast => snoozeDateTime != null && snoozeDateTime!.isBefore(DateTime.now());

  bool get isSnoozedFuture => snoozeDateTime != null && snoozeDateTime!.isAfter(DateTime.now());

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.dateTime,
    this.repetitionData,
    required this.colour,
    this.archived = false,
    this.archivedDateTime,
    this.snoozeDateTime,
  });

  @override
  String toString() {
    return 'NotificationItem(id: $id, title: $title, body: $body, dateTime: $dateTime, repetitionData: $repetitionData, colour: $colour, archived: $archived, archivedDateTime: $archivedDateTime, snoozeDateTime: $snoozeDateTime)';
  }

  DateTime get nextRepeatDateTime {
    if (repetitionData == null) return DateTime.now();

    final now = DateTime.now();
    final lastSent = dateTime ?? now;

    // Return the datetime at which the notification should be sent next. Base it off the last time it was sent.

    switch (repetitionData!.type) {
      case Repetition.hourly:
        return lastSent.add(Duration(hours: repetitionData!.number));
      case Repetition.daily:
        return lastSent.add(Duration(days: repetitionData!.number));
      case Repetition.weekly:
        return lastSent.add(Duration(days: repetitionData!.number * 7));
      case Repetition.monthly:
        return DateTime(lastSent.year, lastSent.month + repetitionData!.number, lastSent.day);
      case Repetition.yearly:
        return DateTime(lastSent.year + repetitionData!.number, lastSent.month, lastSent.day);
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
        'snoozeDateTime': snoozeDateTime?.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
        repetitionData: json['repetitionData'] != null ? RepetitionData.fromJson(json['repetitionData']) : null,
        colour: Color(json['colour']),
        archived: json['archived'] ?? false,
        archivedDateTime: json['archivedDateTime'] != null ? DateTime.parse(json['archivedDateTime']) : null,
        snoozeDateTime: json['snoozeDateTime'] != null ? DateTime.parse(json['snoozeDateTime']) : null,
      );
}
