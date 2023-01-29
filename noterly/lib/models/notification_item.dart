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

  Duration get nextRepeat {
    if (repetitionData == null) {
      return Duration.zero;
    }

    final now = DateTime.now();
    final lastSent = dateTime ?? now;

    switch (repetitionData!.type) {
      case Repetition.hourly:
        return Duration(hours: repetitionData!.interval) - (now.difference(lastSent));
      case Repetition.daily:
        return Duration(days: repetitionData!.interval) - (now.difference(lastSent));
      case Repetition.weekly:
        return Duration(days: repetitionData!.interval * 7) - (now.difference(lastSent));
      case Repetition.monthly:
        var nextMonth = DateTime(lastSent.year, lastSent.month + repetitionData!.interval, lastSent.day);
        return nextMonth.difference(now);
      case Repetition.yearly:
        var nextYear = DateTime(lastSent.year + repetitionData!.interval, lastSent.month, lastSent.day);
        return nextYear.difference(now);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime?.toIso8601String(),
      // 'repeatDuration': repeatDuration?.inMilliseconds,
      'repetitionData': repetitionData?.toJson(),
      'colour': colour.value,
      'archived': archived,
      'archivedDateTime': archivedDateTime?.toIso8601String(),
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      // repeatDuration: json['repeatDuration'] != null ? Duration(milliseconds: json['repeatDuration']) : null,
      repetitionData: RepetitionData.fromJson(json['repetitionData']),
      colour: Color(json['colour']),
      archived: json['archived'] ?? false,
      archivedDateTime: json['archivedDateTime'] != null ? DateTime.parse(json['archivedDateTime']) : null,
    );
  }
}
