import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? text;
  final double? fontSize;

  const CancelButton({super.key, this.onPressed, this.style, this.text, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style:
          style ??
          FilledButton.styleFrom(backgroundColor: Colors.red.shade400, padding: EdgeInsets.zero),
      onPressed: onPressed ?? () => Navigator.of(context).pop(), // Default behavior is to pop
      child: Text(text ?? 'Cancel', style: TextStyle(fontSize: fontSize ?? 14.0)),
    );
  }
}

class OkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? text;
  final double? fontSize;

  const OkButton({super.key, this.onPressed, this.style, this.text, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: style ?? FilledButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      child: Text(text ?? 'OK', style: TextStyle(fontSize: fontSize ?? 14.0)),
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
    return Text(message, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight));
  }
}
