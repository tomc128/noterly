import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

extension DateTimeExtensions on DateTime {
  bool isToday() =>
      DateTime
          .now()
          .year == year && DateTime
          .now()
          .month == month && DateTime
          .now()
          .day == day;

  String toDateOnlyString() => DateFormat.MMMMEEEEd().format(this);

  String toTimeOnlyString() => DateFormat.jm().format(this);

  String toDateTimeString() => DateFormat.MMMMEEEEd().add_jm().format(this);

  String toDateTimeWithYearString() => DateFormat.yMMMMEEEEd().add_jm().format(this);

  String toRelativeDateTimeString({bool alwaysShowDay = false}) {
    final now = DateTime.now();

    bool isToday() => now.year == year && now.month == month && now.day == day;
    bool isYesterday() => now.year == year && now.month == month && now.day - day == 1;
    bool isTomorrow() => now.year == year && now.month == month && now.day - day == -1;
    bool isBeforeNextWeek() => isBefore(now.add(const Duration(days: 7)));

    if (isToday()) return alwaysShowDay ? translate('time.today_and_time', args: {'time': toTimeOnlyString()}) : Jiffy(this).fromNow();

    if (isYesterday()) return translate('time.yesterday_and_time', args: {'time': toTimeOnlyString()});

    if (isTomorrow()) return translate('time.tomorrow_and_time', args: {'time': toTimeOnlyString()});

    if (isBeforeNextWeek()) return translate('time.date_and_time', args: {'date': DateFormat.EEEE().format(this), 'time': toTimeOnlyString()});

    if (year == now.year) return toDateTimeString();

    return toDateTimeWithYearString();
  }

  String toAlmostRelativeDateTimeString() {
    final now = DateTime.now();

    bool isToday() => now.year == year && now.month == month && now.day == day;
    bool isYesterday() => now.year == year && now.month == month && now.day - day == 1;
    bool isTomorrow() => now.year == year && now.month == month && now.day - day == -1;
    bool isBeforeNextWeek() => isBefore(now.add(const Duration(days: 7)));

    if (isToday()) return toTimeOnlyString();

    if (isYesterday()) return translate('time.yesterday_and_time', args: {'time': toTimeOnlyString()});

    if (isTomorrow()) return translate('time.tomorrow_and_time', args: {'time': toTimeOnlyString()});

    if (isBeforeNextWeek()) return translate('time.date_and_time', args: {'date': DateFormat.EEEE().format(this), 'time': toTimeOnlyString()});

    if (year == now.year) return toDateTimeString();

    return toDateTimeWithYearString();
  }

  DateTime toOnlyDate() => DateTime(year, month, day);
}
