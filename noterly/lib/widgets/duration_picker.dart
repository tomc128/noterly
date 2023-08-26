import 'package:flutter/material.dart';
import 'package:noterly/extensions/duration_extensions.dart';
import 'package:noterly/l10n/localisations_util.dart';

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
  int _value = 1;

  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();

    _value = widget.initialDuration.inHours > 0 ? widget.initialDuration.inHours : widget.initialDuration.inMinutes;
    _intervalController = TextEditingController(text: _value.toString());

    _duration = widget.initialDuration;
  }

  @override
  void dispose() {
    _intervalController.dispose();

    super.dispose();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.of(context).dialog_picker_duration_title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: onPrimarySurfaceColor),
                ),
                Text(
                  Strings.of(context).dialog_picker_duration_subtitle(_duration.toRelativeDurationString()),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: onPrimarySurfaceColor),
                ),
              ],
            ),
          ),
          _getMainSection(),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(Strings.of(context).general_cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_duration);
                },
                child: Text(Strings.of(context).general_ok),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMainSection() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: Strings.of(context).dialog_picker_duration_field_number_label,
                ),
                controller: _intervalController,
                onChanged: (value) {
                  if (value.isEmpty) return;
                  var number = int.tryParse(value);
                  if (number == null) return;

                  setState(() {
                    _value = number;
                    _duration = _duration.inHours > 0 ? Duration(hours: number) : Duration(minutes: number);
                  });
                },
                onSubmitted: (value) {
                  var number = int.tryParse(value) ?? 1;

                  setState(() {
                    _value = number;
                    _duration = _duration.inHours > 0 ? Duration(hours: number) : Duration(minutes: number);
                    _intervalController.text = number.toString();
                  });
                },
                onEditingComplete: () {},
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 2,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: Strings.of(context).dialog_picker_duration_field_period_label,
                ),
                items: [
                  DropdownMenuItem(value: 'hour', child: Text(Strings.of(context).time_hours(_value))),
                  DropdownMenuItem(value: 'minute', child: Text(Strings.of(context).time_minutes(_value))),
                ],
                value: _duration.inHours > 0 ? 'hour' : 'minute',
                onChanged: (value) {
                  setState(() {
                    _duration = value == 'hour' ? Duration(hours: _value) : Duration(minutes: _value);
                  });
                },
              ),
            ),
          ],
        ),
      );
}
