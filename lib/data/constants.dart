import 'package:flutter/material.dart';

const List<String> tagOrder = [
  'meat',
  'dairy/eggs',
  'fruit',
  'vegetable',
  'frozen',
  'can',
  'snack',
  'beverage',
  'other',
  '',
];

Color primaryColor = Color.fromARGB(255, 3, 78, 140);

class TextStyles {
  // Dialog title style
  static const TextStyle dialogTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.black,
  );

  // Button text style
  static const TextStyle buttonText = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle tagText = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: Colors.white,
  );

  // Normal text style
  static const TextStyle normalText = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: Colors.black,
  );
}
