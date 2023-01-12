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
}
