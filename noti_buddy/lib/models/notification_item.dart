import 'package:flutter/material.dart';

class NotificationItem {
  String id;

  String title;
  String? body;

  DateTime? dateTime;

  bool persistant;
  Color colour;

  NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.dateTime,
    this.persistant = false,
    required this.colour,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime?.toIso8601String(),
      'persistant': persistant,
      'colour': colour.value,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      dateTime:
          json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      persistant: json['persistant'] ?? false,
      colour: Color(json['colour']),
    );
  }
}
