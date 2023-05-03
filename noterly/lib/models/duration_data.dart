import 'package:flutter_translate/flutter_translate.dart';

enum DurationType {
  hourly('time.hour', 'time.hours'),
  daily('time.day', 'time.days'),
  weekly('time.week', 'time.weeks'),
  monthly('time.month', 'time.months'),
  yearly('time.year', 'time.years');

  final String translationKey;
  final String sTranslationKey;

  const DurationType(this.translationKey, this.sTranslationKey);
}

class DurationData {
  DurationType type = DurationType.daily;
  int number = 1;

  DurationData({
    required this.type,
    required this.number,
  });

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'number': number,
      };

  factory DurationData.fromJson(Map<String, dynamic> json) => DurationData(
        type: DurationType.values[json['type']],
        number: json['number'],
      );

  @override
  String toString() {
    return 'DurationData(type: $type, number: $number)';
  }

  String toReadableString() {
    if (number == 1) {
      return translate(type.translationKey); // i.e. 'hour'
    } else {
      return translate('time.repetition.every.value', args: {'number': number, 'type': translate(type.sTranslationKey)}); // i.e. '2 hours'
    }
  }
}
