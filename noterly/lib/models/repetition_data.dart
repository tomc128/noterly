import 'package:noterly/l10n/localisations_util.dart';
import 'package:noterly/main.dart';

enum Repetition {
  hourly,
  daily,
  weekly,
  monthly,
  yearly;
}

class RepetitionData {
  Repetition type = Repetition.daily;
  int number = 1;

  RepetitionData({
    required this.type,
    required this.number,
  });

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'number': number,
      };

  factory RepetitionData.fromJson(Map<String, dynamic> json) => RepetitionData(
        type: Repetition.values[json['type']],
        number: json['number'],
      );

  @override
  String toString() {
    return 'RepetitionData(type: $type, number: $number)';
  }

  String toReadableString() {
    final context = MyApp.navigatorKey.currentContext!;

    if (number == 1) {
      return switch (type) {
        Repetition.hourly => Strings.of(context).time_hourly,
        Repetition.daily => Strings.of(context).time_daily,
        Repetition.weekly => Strings.of(context).time_weekly,
        Repetition.monthly => Strings.of(context).time_monthly,
        Repetition.yearly => Strings.of(context).time_yearly,
      };
    }

    return Strings.of(context).time_repetition_every_value(
        number,
        switch (type) {
          Repetition.hourly => Strings.of(context).time_hours(number),
          Repetition.daily => Strings.of(context).time_days(number),
          Repetition.weekly => Strings.of(context).time_weeks(number),
          Repetition.monthly => Strings.of(context).time_months(number),
          Repetition.yearly => Strings.of(context).time_years(number),
        });
  }
}
