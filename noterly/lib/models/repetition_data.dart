enum Repetition {
  hourly(0),
  daily(1),
  weekly(2),
  monthly(3),
  yearly(4);

  final int value;
  const Repetition(this.value);
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
}
