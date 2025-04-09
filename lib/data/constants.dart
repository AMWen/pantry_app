import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'classes/tab_configuration.dart';

class HiveBoxNames {
  static const String boxSettings = 'boxSettings';
  static const String tabConfigurations = 'tabConfigurations';
}

class IconDataInfo {
  static const String iconCodePoint = 'iconCodePoint';
  static const String fontFamily = 'fontFamily';
  static const String fontPackage = 'fontPackage';
}

final int defaultCodePoint = 61546;
final String defaultFontFamily = 'FontAwesomeSolid';
final String defaultFontPackage = 'font_awesome_flutter';
final Map<String, dynamic> defaultIconData = {
  IconDataInfo.iconCodePoint: defaultCodePoint,
  IconDataInfo.fontFamily: defaultFontFamily,
  IconDataInfo.fontPackage: defaultFontPackage,
};

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

enum DefaultTabs { pantry, shopping, meals, toeat, todo, ideas }

final defaultTabConfigurations = [
  TabConfiguration(
    title: 'Pantry',
    itemType: 'pantry',
    iconCodePoint: FontAwesomeIcons.jar.codePoint,
    fontFamily: FontAwesomeIcons.jar.fontFamily,
    hasCount: true,
    moveTo: 'shopping',
    sort: DefaultTabs.pantry.index,
  ),
  TabConfiguration(
    title: 'Shopping',
    itemType: 'pantry',
    iconCodePoint: FontAwesomeIcons.cartShopping.codePoint,
    fontFamily: FontAwesomeIcons.cartShopping.fontFamily,
    hasCount: true,
    moveTo: 'pantry',
    sort: DefaultTabs.shopping.index,
  ),
  TabConfiguration(
    title: 'Meals',
    itemType: 'meals',
    iconCodePoint: FontAwesomeIcons.kitchenSet.codePoint,
    fontFamily: FontAwesomeIcons.kitchenSet.fontFamily,
    hasCount: false,
    sort: DefaultTabs.meals.index,
  ),
  TabConfiguration(
    title: 'To Eat',
    itemType: 'meals',
    iconCodePoint: FontAwesomeIcons.utensils.codePoint,
    fontFamily: FontAwesomeIcons.utensils.fontFamily,
    hasCount: false,
    sort: DefaultTabs.toeat.index,
  ),
  TabConfiguration(
    title: 'To Do',
    itemType: 'todo',
    iconCodePoint: FontAwesomeIcons.list.codePoint,
    fontFamily: FontAwesomeIcons.list.fontFamily,
    hasCount: false,
    sort: DefaultTabs.todo.index,
  ),
  TabConfiguration(
    title: 'Ideas',
    itemType: 'ideas',
    iconCodePoint: FontAwesomeIcons.solidLightbulb.codePoint,
    fontFamily: FontAwesomeIcons.solidLightbulb.fontFamily,
    hasCount: false,
    sort: DefaultTabs.ideas.index,
  ),
];

String lowercaseAndRemoveSpaces(String input) {
  return input.replaceAll(' ', '').toLowerCase();
}

final DateTime defaultDateTime = DateTime.utc(2000, 1, 1);

final List<Map<String, String>> sortOptions = [
  {'title': 'None', 'value': ''},
  {'title': 'Name', 'value': 'name'},
  {'title': 'Date Added', 'value': 'dateAdded'},
  {'title': 'Tag', 'value': 'tag'},
];

Color primaryColor = Color.fromARGB(255, 3, 78, 140);
Color secondaryColor = Colors.grey[200]!;
Color dullColor = Colors.grey[500]!;

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
