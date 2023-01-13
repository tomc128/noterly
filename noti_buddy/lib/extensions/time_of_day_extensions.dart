import 'package:flutter/material.dart';

extension TimeOfDayExtensions on TimeOfDay {
  bool isAfterNow() {
    var now = TimeOfDay.now();
    return hour > now.hour || (hour == now.hour && minute > now.minute);
  }
}
