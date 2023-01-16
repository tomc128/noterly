import 'package:flutter/material.dart';

class NotificationItem {
  String id;

  String title;
  String? body;

  DateTime? dateTime;

  bool persistent;
  Color colour;

  bool archived;
  DateTime? archivedDateTime;

  NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.dateTime,
    this.persistent = false,
    required this.colour,
    this.archived = false,
    this.archivedDateTime,
  });

  @override
  String toString() {
    return 'NotificationItem(id: $id, title: $title, body: $body, dateTime: $dateTime, persistent: $persistent, colour: $colour, archived: $archived)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime?.toIso8601String(),
      'persistent': persistent,
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
      persistent: json['persistent'] ?? false,
      colour: Color(json['colour']),
      archived: json['archived'] ?? false,
      archivedDateTime: json['archivedDateTime'] != null ? DateTime.parse(json['archivedDateTime']) : null,
    );
  }
}
