extension DurationExtensions on Duration {
  String toRelativeDurationString() {
    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;

    final daysString = days == 0
        ? ''
        : days == 1
            ? '1 day'
            : '$days days';
    final hoursString = hours == 0
        ? ''
        : hours == 1
            ? '1 hour'
            : '$hours hours';
    final minutesString = minutes == 0
        ? ''
        : minutes == 1
            ? '1 minute'
            : '$minutes minutes';

    final combined = '$daysString, $hoursString, $minutesString'.trim();
    return combined.replaceAll(RegExp(r', ,'), ',').replaceAll(RegExp(r',$'), '').replaceAll(RegExp(r'^,\s*'), ''); // Remove trailing, leading or double commas
  }
}
