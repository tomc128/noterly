extension DurationExtensions on Duration {
  String toRelativeDurationString() {
    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    final daysString = days == 1 ? '1 day' : '$days days';
    final hoursString = hours == 1 ? '1 hour' : '$hours hours';
    final minutesString = minutes == 1 ? '1 minute' : '$minutes minutes';
    final secondsString = seconds == 1 ? '1 second' : '$seconds seconds';

    if (days > 0) return daysString;
    if (hours > 0) return hoursString;
    if (minutes > 0) return minutesString;
    return secondsString;
  }
}
