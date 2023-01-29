enum Repetition {
  hourly(0, 'hours'),
  daily(1, 'days'),
  weekly(2, 'weeks'),
  monthly(3, 'months'),
  yearly(4, 'years');

  final int value;
  final String pluralName;
  const Repetition(this.value, this.pluralName);
}

class RepetitionData {
  Repetition type = Repetition.daily;
  int interval = 1;

  RepetitionData({
    required this.type,
    required this.interval,
  });

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'interval': interval,
      };

  factory RepetitionData.fromJson(Map<String, dynamic> json) => RepetitionData(
        type: Repetition.values[json['type']],
        interval: json['interval'],
      );

  @override
  String toString() {
    return 'RepetitionData(type: $type, interval: $interval)';
  }

  String toReadableString() {
    if (interval == 1) {
      return type.name;
    } else {
      return 'every $interval ${type.pluralName}';
    }
  }
}
