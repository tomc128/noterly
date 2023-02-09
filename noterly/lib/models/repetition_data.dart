import 'package:flutter_translate/flutter_translate.dart';

enum Repetition {
  hourly('time.hourly', 'time.hours'),
  daily('time.daily', 'time.days'),
  weekly('time.weekly', 'time.weeks'),
  monthly('time.monthly', 'time.months'),
  yearly('time.yearly', 'time.years');

  final String lyTranslationKey;
  final String sTranslationKey;

  const Repetition(this.lyTranslationKey, this.sTranslationKey);
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
    if (number == 1) {
      return translate(type.lyTranslationKey); // i.e. 'hourly'
    } else {
      return translate('time.repetition.every.value', args: {'number': number, 'type': translate(type.sTranslationKey)}); // i.e. 'every 2 hours'
    }
  }
}
