import 'package:flutter/material.dart';

final Map<String, List<String>> itemTypeTagMapping = {
  'pantry': [
    'meat',
    'grain',
    'fruit',
    'vegetable',
    'dairy/eggs',
    'frozen',
    'can',
    'snack',
    'beverage',
    'other',
    '',
  ],
  'todo': [
    'urgent',
    'high priority',
    'medium priority',
    'low priority',
    'completed',
    '',
  ],
  'meals': [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
    'dessert',
    '',
  ],
};

final List<String> pantryTagOrder = itemTypeTagMapping['pantry']!;

Color primaryColor = Color.fromARGB(255, 3, 78, 140);
Color secondaryColor = Colors.grey[200]!;

class TextStyles {
   static TextStyle titleText = TextStyle(
    color: secondaryColor,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.black,
  );

  static TextStyle buttonText = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: secondaryColor,
  );

  static TextStyle tagText = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: secondaryColor,
  );

  static const TextStyle lightText = TextStyle(
    color: Colors.grey,
    fontSize: 10,
    fontWeight: FontWeight.w300,
    height: 2.2,
  );

  static const TextStyle normalText = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: Colors.black,
  );
}
