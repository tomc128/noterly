import 'package:flutter/material.dart';

Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialDuration,
}) async {
  var dialog = DurationPicker(
    initialDuration: initialDuration,
  );

  return showDialog<Duration>(
    context: context,
    builder: (context) => dialog,
  );
}

class DurationPicker extends StatefulWidget {
  final Duration initialDuration;

  const DurationPicker({
    required this.initialDuration,
    super.key,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late Duration _duration;

  @override
  void initState() {
    super.initState();

    _duration = widget.initialDuration;
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
              'Select repeat duration',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: onPrimarySurfaceColor),
            ),
          ),
          _getMinutePicker(),
          _getHourPicker(),
          _getDayPicker(),
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
                  Navigator.of(context).pop(_duration);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMinutePicker() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Minutes', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  var newDuration = _duration - const Duration(minutes: 1);

                  if (newDuration.isNegative) {
                    newDuration = Duration.zero;
                  }

                  _duration = newDuration;
                });
              },
              icon: const Icon(Icons.remove),
            ),
            // calculate the number of minutes in the duration, ignoring hours
            Text((_duration.inMinutes % 60).toString()),
            IconButton(
              onPressed: () {
                setState(() {
                  var newDuration = _duration + const Duration(minutes: 1);

                  _duration = newDuration;
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      );

  Widget _getHourPicker() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hours', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  var newDuration = _duration - const Duration(hours: 1);

                  if (newDuration.isNegative) {
                    newDuration = Duration.zero;
                  }

                  _duration = newDuration;
                });
              },
              icon: const Icon(Icons.remove),
            ),
            // calculate the number of hours in the duration, ignoring days
            Text((_duration.inHours % 24).toString()),
            IconButton(
              onPressed: () {
                setState(() {
                  var newDuration = _duration + const Duration(hours: 1);

                  _duration = newDuration;
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      );

  Widget _getDayPicker() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Days', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  var newDuration = _duration - const Duration(days: 1);

                  if (newDuration.isNegative) {
                    newDuration = Duration.zero;
                  }

                  _duration = newDuration;
                });
              },
              icon: const Icon(Icons.remove),
            ),
            Text(_duration.inDays.toString()),
            IconButton(
              onPressed: () {
                setState(() {
                  var newDuration = _duration + const Duration(days: 1);

                  _duration = newDuration;
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      );
}
