import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';

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
                    if (_dateTime.isAfter(widget.firstDate)) {
                      _dateTime = _dateTime.subtract(const Duration(days: 1));
                    }
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(_dateTime.toDateOnlyString()),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_dateTime.isBefore(widget.lastDate)) {
                      _dateTime = _dateTime.add(const Duration(days: 1));
                    }
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed: () {},
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
                    _dateTime = _dateTime.subtract(const Duration(hours: 1));
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(_dateTime.toTimeOnlyString()),
              IconButton(
                onPressed: () {
                  setState(() {
                    _dateTime = _dateTime.add(const Duration(hours: 1));
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed: () {},
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
                  Navigator.of(context).pop();
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
