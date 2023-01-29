import 'package:noterly/managers/log.dart';

enum Repetition {
  hourly('hours'),
  daily('days'),
  weekly('weeks'),
  monthly('months'),
  yearly('years');

  final String pluralName;
  const Repetition(this.pluralName);
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

  factory RepetitionData.fromJson(Map<String, dynamic> json) {
    Log.logger.d([
      'RepetitionData.fromJson: $json',
      'json.type = ${json['type']}',
      'Repetition.values[json.type] = ${Repetition.values[json['type']]}',
    ]);

    return RepetitionData(
      type: Repetition.values[json['type']],
      number: json['number'],
    );
  }

  @override
  String toString() {
    return 'RepetitionData(type: $type, number: $number)';
  }

  String toReadableString() {
    if (number == 1) {
      return type.name;
    } else {
      return 'every $number ${type.pluralName}';
    }
  }
}
