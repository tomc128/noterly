import 'package:flutter/material.dart';
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
                  'Select repeat duration',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: onPrimarySurfaceColor),
                ),
                Text(
                  'repeats ${_repetitionData.toReadableString()}',
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_repetitionData);
                },
                child: const Text('OK'),
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number',
                ),
                controller: _intervalController,
                onSubmitted: (value) {
                  setState(() {
                    _repetitionData.number = int.parse(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 2,
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Period',
                ),
                items: [
                  DropdownMenuItem(value: Repetition.hourly, child: Text('Hour${_repetitionData.number == 1 ? '' : 's'}')),
                  DropdownMenuItem(value: Repetition.daily, child: Text('Day${_repetitionData.number == 1 ? '' : 's'}')),
                  DropdownMenuItem(value: Repetition.weekly, child: Text('Week${_repetitionData.number == 1 ? '' : 's'}')),
                  DropdownMenuItem(value: Repetition.monthly, child: Text('Month${_repetitionData.number == 1 ? '' : 's'}')),
                  DropdownMenuItem(value: Repetition.yearly, child: Text('Year${_repetitionData.number == 1 ? '' : 's'}')),
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
