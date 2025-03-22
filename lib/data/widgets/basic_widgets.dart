import 'package:flutter/material.dart';

import '../constants.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CancelButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent, // Red color for Cancel button
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(), // Default behavior is to pop
      child: Text('Cancel', style: TextStyles.buttonText),
    );
  }
}

class AlertTitle extends StatelessWidget {
  final String message;
  final double fontSize;

  const AlertTitle(
    this.message, {
    super.key,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(fontSize: fontSize),
    );
  }
}
