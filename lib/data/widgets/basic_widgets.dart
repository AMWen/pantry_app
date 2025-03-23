import 'package:flutter/material.dart';

import '../constants.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CancelButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red.shade400, // Red color for Cancel button
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(), // Default behavior is to pop
      child: Text('Cancel', style: TextStyles.buttonText),
    );
  }
}

class AlertTitle extends StatelessWidget {
  final String message;
  final double fontSize;
  final FontWeight fontWeight;

  const AlertTitle(
    this.message, {
    super.key,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }
}
