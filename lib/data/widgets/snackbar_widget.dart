import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String message) {
  Duration duration = message.contains('Error') ? Duration(milliseconds: 1500) : Duration(milliseconds: 700);
  
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), duration: duration));
}
