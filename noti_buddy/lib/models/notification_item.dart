import 'package:flutter/material.dart';

class NotificationItem {
  String title;
  String? body;

  DateTime? dateTime;

  Color colour;

  NotificationItem({
    required this.title,
    this.body,
    this.dateTime,
    required this.colour,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'dateTime': dateTime?.toIso8601String(),
      'colour': colour.value,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'],
      body: json['body'],
      dateTime:
          json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      colour: Color(json['colour']),
    );
  }
}
