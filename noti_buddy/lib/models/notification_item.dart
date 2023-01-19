import 'package:flutter/material.dart';

class NotificationItem {
  String id;

  String title;
  String? body;

  Color colour;

  DateTime? dateTime;

  bool archived;
  DateTime? archivedDateTime;

  NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.dateTime,
    required this.colour,
    this.archived = false,
    this.archivedDateTime,
  });

  @override
  String toString() {
    return 'NotificationItem(id: $id, title: $title, body: $body, dateTime: $dateTime, colour: $colour, archived: $archived)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime?.toIso8601String(),
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
      colour: Color(json['colour']),
      archived: json['archived'] ?? false,
      archivedDateTime: json['archivedDateTime'] != null ? DateTime.parse(json['archivedDateTime']) : null,
    );
  }
}
