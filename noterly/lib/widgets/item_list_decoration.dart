import 'package:flutter/material.dart';

class ItemListDecoration extends StatelessWidget {
  final Color colour;

  const ItemListDecoration({
    required this.colour,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Align(
        alignment: Alignment.center,
        child: CircleAvatar(
          radius: 8,
          backgroundColor: colour,
        ),
      ),
    );
  }
}
