import 'package:flutter/material.dart';

Future<Color?> showColourPicker({
  required BuildContext context,
  required Color initialColour,
}) async {
  var dialog = ColourPicker(
    initialColour: initialColour,
  );

  return showDialog<Color>(
    context: context,
    builder: (context) => dialog,
  );
}

Map<String, Color> colours = {
  'red': Colors.red,
  'green': Colors.green,
  'blue': Colors.blue,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'orange': Colors.orange,
  'yellow': Colors.yellow,
  'teal': Colors.teal,
  'cyan': Colors.cyan,
  'indigo': Colors.indigo,
  'brown': Colors.brown,
  'grey': Colors.grey,
};

class ColourPicker extends StatefulWidget {
  final Color initialColour;

  const ColourPicker({
    required this.initialColour,
    super.key,
  });

  @override
  State<ColourPicker> createState() => _ColourPickerState();
}

class _ColourPickerState extends State<ColourPicker> {
  late Color _colour;

  @override
  void initState() {
    super.initState();

    _colour = widget.initialColour;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Text(
              'Select colour',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 64,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            itemCount: colours.length,
            itemBuilder: (context, index) {
              var colour = colours.values.elementAt(index);

              return GestureDetector(
                onTap: () {
                  if (_colour == colour) {
                    // Second tap - submit dialog
                    Navigator.of(context).pop(_colour);
                  } else {
                    // First tap - select colour
                    setState(() {
                      _colour = colour;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colour,
                    border: Border.all(
                      color: _colour == colour ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(color: colour.withOpacity(0.25), blurRadius: 2, offset: const Offset(0, 3)),
                    ],
                  ),
                ),
              );
            },
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
                  Navigator.of(context).pop(_colour);
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
