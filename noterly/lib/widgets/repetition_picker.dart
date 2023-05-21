import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:noterly/models/repetition_data.dart';

Future<RepetitionData?> showRepetitionPicker({
  required BuildContext context,
  required RepetitionData initialRepetitionData,
}) async {
  var dialog = RepetitionPicker(
    initialRepetitionData: initialRepetitionData,
  );

  return showDialog<RepetitionData>(
    context: context,
    builder: (context) => dialog,
  );
}

class RepetitionPicker extends StatefulWidget {
  final RepetitionData initialRepetitionData;

  const RepetitionPicker({
    required this.initialRepetitionData,
    super.key,
  });

  @override
  State<RepetitionPicker> createState() => _RepetitionPickerState();
}

class _RepetitionPickerState extends State<RepetitionPicker> {
  late RepetitionData _repetitionData;

  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();

    _intervalController = TextEditingController(text: widget.initialRepetitionData.number.toString());

    _repetitionData = widget.initialRepetitionData;
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
                  translate('dialog.picker.repetition.title'),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: onPrimarySurfaceColor),
                ),
                Text(
                  translate('dialog.picker.repetition.subtitle', args: {'duration': _repetitionData.toReadableString()}),
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
                child: Text(translate('general.cancel')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_repetitionData);
                },
                child: Text(translate('general.ok')),
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
                  labelText: translate('dialog.picker.repetition.field.number.label'),
                ),
                controller: _intervalController,
                onChanged: (value) {
                  if (value.isEmpty) return;

                  var number = int.tryParse(value);
                  if (number == null) return;
                  if (number < 1) number = 1;

                  setState(() {
                    _repetitionData.number = number!;
                  });
                },
                onSubmitted: (value) {
                  var number = int.tryParse(value) ?? 1;
                  if (number < 1) number = 1;

                  setState(() {
                    _repetitionData.number = number;
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
                  labelText: translate('dialog.picker.repetition.field.period.label'),
                ),
                items: [
                  DropdownMenuItem(value: Repetition.hourly, child: Text(translate('time.hour${_repetitionData.number == 1 ? '' : 's'}'))),
                  DropdownMenuItem(value: Repetition.daily, child: Text(translate('time.day${_repetitionData.number == 1 ? '' : 's'}'))),
                  DropdownMenuItem(value: Repetition.weekly, child: Text(translate('time.week${_repetitionData.number == 1 ? '' : 's'}'))),
                  DropdownMenuItem(value: Repetition.monthly, child: Text(translate('time.month${_repetitionData.number == 1 ? '' : 's'}'))),
                  DropdownMenuItem(value: Repetition.yearly, child: Text(translate('time.year${_repetitionData.number == 1 ? '' : 's'}'))),
                ],
                value: _repetitionData.type,
                onChanged: (value) {
                  setState(() {
                    _repetitionData.type = value!;
                  });
                },
              ),
            ),
          ],
        ),
      );
}
