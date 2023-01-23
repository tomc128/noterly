import 'package:flutter/material.dart';

Future<Duration?> showDurationPicker({
  required BuildContext context,
}) async {
  var dialog = const DurationPicker();

  return showDialog<Duration>(
    context: context,
    builder: (context) => dialog,
  );
}

class DurationPicker extends StatefulWidget {
  const DurationPicker({
    super.key,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  var _duration = const Duration();

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
                  _duration = Duration.zero;
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
}
