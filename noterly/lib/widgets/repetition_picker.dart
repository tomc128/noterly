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

  @override
  void initState() {
    super.initState();

    _repetitionData = widget.initialRepetitionData;
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
                  'every $_repetitionData',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: onPrimarySurfaceColor),
                ),
              ],
            ),
          ),

          _getMainSection(),
          const Divider(thickness: 0),
          _getSpecifierSection(),

          // _getMinutePicker(),
          // _getHourPicker(),
          // _getDayPicker(),
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

  Widget _getMainSection() => Row(
        children: [
          const TextField(),
          DropdownButton(items: const [
            DropdownMenuItem(value: 'day', child: Text('Days')),
            DropdownMenuItem(value: 'week', child: Text('Weeks')),
            DropdownMenuItem(value: 'month', child: Text('Weeks')),
            DropdownMenuItem(value: 'year', child: Text('Weeks')),
          ], onChanged: (value) {}),
        ],
      );

  Widget _getSpecifierSection() => Row();

  // Widget _getMinutePicker() => Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text('Minutes', style: Theme.of(context).textTheme.titleMedium),
  //           const Spacer(),
  //           IconButton(
  //             onPressed: () {
  //               setState(() {
  //                 var newDuration = _duration - const Duration(minutes: 1);

  //                 if (newDuration.isNegative) {
  //                   newDuration = Duration.zero;
  //                 }

  //                 _duration = newDuration;
  //               });
  //             },
  //             icon: const Icon(Icons.remove),
  //           ),
  //           // calculate the number of minutes in the duration, ignoring hours
  //           Text((_duration.inMinutes % 60).toString()),
  //           IconButton(
  //             onPressed: () {
  //               setState(() {
  //                 var newDuration = _duration + const Duration(minutes: 1);

  //                 _duration = newDuration;
  //               });
  //             },
  //             icon: const Icon(Icons.add),
  //           ),
  //         ],
  //       ),
  //     );

  // Widget _getHourPicker() => Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text('Hours', style: Theme.of(context).textTheme.titleMedium),
  //           const Spacer(),
  //           IconButton(
  //             onPressed: () {
  //               setState(() {
  //                 var newDuration = _duration - const Duration(hours: 1);

  //                 if (newDuration.isNegative) {
  //                   newDuration = Duration.zero;
  //                 }

  //                 _duration = newDuration;
  //               });
  //             },
  //             icon: const Icon(Icons.remove),
  //           ),
  //           // calculate the number of hours in the duration, ignoring days
  //           Text((_duration.inHours % 24).toString()),
  //           IconButton(
  //             onPressed: () {
  //               setState(() {
  //                 var newDuration = _duration + const Duration(hours: 1);

  //                 _duration = newDuration;
  //               });
  //             },
  //             icon: const Icon(Icons.add),
  //           ),
  //         ],
  //       ),
  //     );

  // Widget _getDayPicker() => Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //   child: Row(
  //     mainAxisAlignment = MainAxisAlignment.center,
  //     children = [
  //       Text('Days', style: Theme.of(context).textTheme.titleMedium),
  //       const Spacer(),
  //       IconButton(
  //         onPressed: () {
  //           setState(() {
  //             var newDuration = _duration - const Duration(days: 1);

  //             if (newDuration.isNegative) {
  //               newDuration = Duration.zero;
  //             }

  //             _duration = newDuration;
  //           });
  //         },
  //         icon: const Icon(Icons.remove),
  //       ),
  //       Text(_duration.inDays.toString()),
  //       IconButton(
  //         onPressed: () {
  //           setState(() {
  //             var newDuration = _duration + const Duration(days: 1);

  //             _duration = newDuration;
  //           });
  //         },
  //         icon: const Icon(Icons.add),
  //       ),
  //     ],
  //   ),
  // );
}
