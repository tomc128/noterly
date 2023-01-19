import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

extension DateTimeExtensions on DateTime {
  bool isToday() => DateTime.now().year == year && DateTime.now().month == month && DateTime.now().day == day;

  String toDateOnlyString() => DateFormat.MMMMEEEEd().format(this);

  String toTimeOnlyString() => DateFormat.jm().format(this);

  String toDateTimeString() => DateFormat.MMMMEEEEd().add_jm().format(this);

  String toRelativeDateTimeString({bool alwaysShowDay = false}) {
    final now = DateTime.now();

    bool isToday() => now.year == year && now.month == month && now.day == day;

    bool isYesterday() => now.year == year && now.month == month && now.day - day == 1;

    bool isTomorrow() => now.year == year && now.month == month && now.day - day == -1;

    bool isBeforeNextWeek() => isBefore(now.add(const Duration(days: 7)));

    if (isToday()) return alwaysShowDay ? 'Today, ${toTimeOnlyString()}' : Jiffy(this).fromNow();

    if (isYesterday()) return 'Yesterday, ${toTimeOnlyString()}';

    if (isTomorrow()) return 'Tomorrow, ${toTimeOnlyString()}';

    if (isBeforeNextWeek()) return '${DateFormat.EEEE().format(this)}, ${toTimeOnlyString()}';

    return toDateTimeString();
  }
}
