import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';
import 'package:noti_buddy/extensions/time_of_day_extensions.dart';

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  firstDate = DateUtils.dateOnly(firstDate);
  lastDate = DateUtils.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    'lastDate $lastDate must be on or after firstDate $firstDate.',
  );
  assert(
    !initialDateTime.isBefore(firstDate),
    'initialDateTime $initialDateTime must be on or after firstDate $firstDate.',
  );
  assert(
    !initialDateTime.isAfter(lastDate),
    'initialDateTime $initialDateTime must be on or before lastDate $lastDate.',
  );

  var dialog = DateTimePicker(
    initialDate: initialDateTime,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  return showDialog<DateTime>(
    context: context,
    builder: (context) => dialog,
  );
}

class DateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const DateTimePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    super.key,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();

    _dateTime = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Select date and time',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          const Text('Date'),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    var newDateTime =
                        _dateTime.subtract(const Duration(days: 1));
                    if (newDateTime.isAfter(widget.firstDate)) {
                      _dateTime = newDateTime;
                    }
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(_dateTime.toDateOnlyString()),
              IconButton(
                onPressed: () {
                  setState(() {
                    var newDateTime = _dateTime.add(const Duration(days: 1));
                    if (newDateTime.isBefore(widget.lastDate)) {
                      _dateTime = newDateTime;
                    }
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: _dateTime,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        _dateTime = value;
                      });
                    }
                  });
                },
                icon: const Icon(Icons.calendar_today),
              ),
            ],
          ),
          const Text('Time'),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    var newDateTime =
                        _dateTime.subtract(const Duration(hours: 1));
                    if (newDateTime.isAfter(widget.firstDate)) {
                      _dateTime = newDateTime;
                    }
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(_dateTime.toTimeOnlyString()),
              IconButton(
                onPressed: () {
                  setState(() {
                    var newDateTime = _dateTime.add(const Duration(hours: 1));
                    if (newDateTime.isBefore(widget.lastDate)) {
                      _dateTime = newDateTime;
                    }
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dateTime),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        if (value.isAfterNow()) {
                          _dateTime = DateTime(
                            _dateTime.year,
                            _dateTime.month,
                            _dateTime.day,
                            value.hour,
                            value.minute,
                          );
                        } else {
                          print('invalid time');
                        }
                      });
                    }
                  });
                },
                icon: const Icon(Icons.access_time),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_dateTime);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
