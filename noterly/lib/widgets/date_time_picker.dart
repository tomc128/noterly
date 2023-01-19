import 'package:flutter/material.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/extensions/time_of_day_extensions.dart';

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // The header should use the primary color in light themes and surface color in dark
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color primarySurfaceColor = isDark ? colorScheme.surface : colorScheme.primary;
    final Color onPrimarySurfaceColor = isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              color: primarySurfaceColor,
            ),
            child: Text(
              'Select date and time',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: onPrimarySurfaceColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Date', style: Theme.of(context).textTheme.titleMedium),
          ),
          _getDatePicker(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Time', style: Theme.of(context).textTheme.titleMedium),
          ),
          _getTimePicker(),
          ButtonBar(
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

  Widget _getDatePicker() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    var newDateTime = _dateTime.subtract(const Duration(days: 1));
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
            ],
          ),
          TextButton.icon(
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
            icon: const Icon(Icons.calendar_month),
            label: const Text('Select date'),
          ),
        ],
      );

  Widget _getTimePicker() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    var newDateTime = _dateTime.subtract(const Duration(hours: 1));
                    if (newDateTime.isAfter(widget.firstDate)) {
                      _dateTime = newDateTime;
                    }
                  });
                },
                icon: const Icon(Icons.remove),
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
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_dateTime),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    if (_dateTime.isToday() && !value.isAfterNow()) {
                      print('invalid time!');
                      return;
                    }

                    _dateTime = DateTime(
                      _dateTime.year,
                      _dateTime.month,
                      _dateTime.day,
                      value.hour,
                      value.minute,
                    );
                  });
                }
              });
            },
            icon: const Icon(Icons.timer),
            label: const Text('Select time'),
          ),
        ],
      );
}
