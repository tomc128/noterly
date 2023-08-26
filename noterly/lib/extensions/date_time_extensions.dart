import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:noterly/l10n/localisations_util.dart';
import 'package:noterly/main.dart';

extension DateTimeExtensions on DateTime {
  bool isToday() => DateTime.now().year == year && DateTime.now().month == month && DateTime.now().day == day;

  String toDateOnlyString() => DateFormat.MMMMEEEEd().format(this);

  String toTimeOnlyString() => DateFormat.jm().format(this);

  String toDateTimeString() => DateFormat.MMMMEEEEd().add_jm().format(this);

  String toDateTimeWithYearString() => DateFormat.yMMMMEEEEd().add_jm().format(this);

  String toRelativeDateTimeString({bool alwaysShowDay = false}) {
    final now = DateTime.now();
    final context = MyApp.navigatorKey.currentContext!;

    bool isToday() => now.year == year && now.month == month && now.day == day;
    bool isYesterday() => now.year == year && now.month == month && now.day - day == 1;
    bool isTomorrow() => now.year == year && now.month == month && now.day - day == -1;
    bool isBeforeNextWeek() => isBefore(now.add(const Duration(days: 7)));

    if (isToday()) return alwaysShowDay ? Strings.of(context).time_todayAndTime(toTimeOnlyString()) : Jiffy.parseFromDateTime(this).fromNow();

    if (isYesterday()) return Strings.of(context).time_yesterdayAndTime(toTimeOnlyString());

    if (isTomorrow()) return Strings.of(context).time_tomorrowAndTime(toTimeOnlyString());

    if (isBeforeNextWeek()) return Strings.of(context).time_dateAndTime(DateFormat.EEEE().format(this), toTimeOnlyString());

    if (year == now.year) return toDateTimeString();

    return toDateTimeWithYearString();
  }

  String toSnoozedUntilDateTimeString() {
    final now = DateTime.now();
    final context = MyApp.navigatorKey.currentContext!;

    bool isToday() => now.year == year && now.month == month && now.day == day;
    bool isYesterday() => now.year == year && now.month == month && now.day - day == 1;
    bool isTomorrow() => now.year == year && now.month == month && now.day - day == -1;
    bool isBeforeNextWeek() => isBefore(now.add(const Duration(days: 7)));

    if (isToday()) return Strings.of(context).time_snooze_until(toTimeOnlyString());

    if (isYesterday()) {
      return Strings.of(context).time_snooze_until(Strings.of(context).time_yesterdayAndTime(toTimeOnlyString()));
    }

    if (isTomorrow()) {
      return Strings.of(context).time_snooze_until(Strings.of(context).time_tomorrowAndTime(toTimeOnlyString()));
    }

    if (isBeforeNextWeek()) {
      return Strings.of(context).time_snooze_until(Strings.of(context).time_dateAndTime(DateFormat.EEEE().format(this), toTimeOnlyString()));
    }

    if (year == now.year) return Strings.of(context).time_snooze_until(toDateTimeString());

    return toDateTimeWithYearString();
  }

  DateTime toOnlyDate() => DateTime(year, month, day);
}
