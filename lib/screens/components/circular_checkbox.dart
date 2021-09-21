import 'package:flutter/material.dart';
import 'package:zpevnik/theme.dart';

class CircularCheckbox extends StatelessWidget {
  final bool selected;

  const CircularCheckbox({Key? key, required this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: selected
          ? Icon(Icons.check_circle, color: AppTheme.of(context).chordColor)
          : Icon(Icons.radio_button_off, color: Colors.grey),
    );
  }
}
