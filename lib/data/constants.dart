import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'classes/tab_configuration.dart';

class HiveBoxNames {
  static const String boxSettings = 'boxSettings';
  static const String tabConfigurations = 'tabConfigurations';
}

Map<String, String> defaultItemTypesFromConfigurations() {
  return Map.fromEntries(
    defaultTabConfigurations.map(
      (config) => MapEntry(lowercaseAndRemoveSpaces(config.title), config.itemType),
    ),
  );
}

final Map<String, List<String>> defaultTagMapping = {
  'pantry': [
    'meat',
    'protein',
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
  'ideas': ['easy', 'moderate', 'difficult', 'useful', 'fun', ''],
};

final defaultTabConfigurations = [
  TabConfiguration(
    title: 'Pantry',
    itemType: 'pantry',
    iconCodePoint: Icons.kitchen_rounded.codePoint,
    hasCount: true,
    moveTo: 'shopping',
  ),
  TabConfiguration(
    title: 'Shopping',
    itemType: 'shopping',
    iconCodePoint: Icons.local_grocery_store.codePoint,
    hasCount: true,
    moveTo: 'pantry',
  ),
  TabConfiguration(
    title: 'Meals',
    itemType: 'meals',
    iconCodePoint: Icons.dinner_dining.codePoint,
    hasCount: false,
  ),
  TabConfiguration(
    title: 'To Eat',
    itemType: 'meals',
    iconCodePoint: Icons.local_dining.codePoint,
    hasCount: false,
  ),
  TabConfiguration(
    title: 'To Do',
    itemType: 'meals',
    iconCodePoint: Icons.list.codePoint,
    hasCount: false,
  ),
  TabConfiguration(
    title: 'Ideas',
    itemType: 'ideas',
    iconCodePoint: Icons.lightbulb.codePoint,
    hasCount: false,
  ),
];

String lowercaseAndRemoveSpaces(String input) {
  return input.replaceAll(' ', '').toLowerCase();
}

final int defaultCodePoint = 58408;

final DateTime defaultDateTime = DateTime.utc(2000, 1, 1);

final List<Map<String, String>> sortOptions = [
  {'title': 'None', 'value': ''},
  {'title': 'Name', 'value': 'name'},
  {'title': 'Date Added', 'value': 'dateAdded'},
  {'title': 'Tag', 'value': 'tag'},
];

Color primaryColor = Color.fromARGB(255, 3, 78, 140);
Color secondaryColor = Colors.grey[200]!;
Color dullColor = Colors.grey[600]!;

DateFormat dateFormat = DateFormat('M/d/yy');

EdgeInsets alertPadding = EdgeInsets.symmetric(vertical: 10, horizontal: 20);

class TextStyles {
  static TextStyle titleText = TextStyle(
    // color: secondaryColor,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    // color: Colors.black,
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

  static const TextStyle hintText = TextStyle(
    color: Colors.grey,
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle mediumText = TextStyle(fontSize: 13);

  static const TextStyle normalText = TextStyle(fontWeight: FontWeight.normal, fontSize: 14);

  static const TextStyle boldText = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
}
