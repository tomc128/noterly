import 'package:flutter_translate/flutter_translate.dart';

extension DurationExtensions on Duration {
  String toRelativeDurationString() {
    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;

    final daysString = days == 0
        ? ''
        : days == 1
            ? '1 ${translate('time.day')}'
            : translate('time.days.value', args: {'value': days});
    final hoursString = hours == 0
        ? ''
        : hours == 1
            ? '1 ${translate('time.hour')}'
            : translate('time.hours.value', args: {'value': hours});
    final minutesString = minutes == 0
        ? ''
        : minutes == 1
            ? '1 ${translate('time.minute')}'
            : translate('time.minutes.value', args: {'value': minutes});

    final combined = '$daysString, $hoursString, $minutesString'.trim();
    return combined.replaceAll(RegExp(r', ,'), ',').replaceAll(RegExp(r',$'), '').replaceAll(RegExp(r'^,\s*'), ''); // Remove trailing, leading or double commas
  }
}
