import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

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
  'todo': ['urgent', 'high priority', 'low priority', ''],
  'meals': ['breakfast', 'lunch', 'dinner', 'snack', 'dessert', ''],
};

final List<String> boxNames = ['pantry', 'shopping', 'todo', 'meals'];

final List<Map<String, String>> sortOptions = [
  {'title': 'None', 'value': ''},
  {'title': 'Name', 'value': 'name'},
  {'title': 'Date Added', 'value': 'dateAdded'},
  {'title': 'Tag', 'value': 'tag'},
];

Color primaryColor = Color.fromARGB(255, 3, 78, 140);
Color secondaryColor = Colors.grey[200]!;

DateFormat dateFormat = DateFormat('M/d/yy');

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
    fontWeight: FontWeight.w500,
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
