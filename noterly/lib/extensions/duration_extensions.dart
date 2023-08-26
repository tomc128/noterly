import 'package:noterly/l10n/localisations_util.dart';
import 'package:noterly/main.dart';

extension DurationExtensions on Duration {
  String toRelativeDurationString() {
    final days = inDays;
    final hours = inHours % 24;
    final minutes = inMinutes % 60;

    final context = MyApp.navigatorKey.currentContext!;

    final daysString = days == 0 ? '' : Strings.of(context).time_days_value(days);
    final hoursString = hours == 0 ? '' : Strings.of(context).time_hours_value(hours);
    final minutesString = minutes == 0 ? '' : Strings.of(context).time_minutes_value(minutes);

    final combined = '$daysString, $hoursString, $minutesString'.trim();
    return combined.replaceAll(RegExp(r', ,'), ',').replaceAll(RegExp(r',$'), '').replaceAll(RegExp(r'^,\s*'), ''); // Remove trailing, leading or double commas
  }
}
