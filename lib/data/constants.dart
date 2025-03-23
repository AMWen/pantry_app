import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../screens/additem_screen.dart';
import '../screens/base_screen.dart';
import '../screens/simplelist_screen.dart';
import 'classes/list_item.dart';
import 'classes/tab_item.dart';

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

final List<String> boxNames = tabItems.keys.toList();

String lowercaseAndRemoveSpaces(String input) {
  return input.replaceAll(' ', '').toLowerCase();
}

// Primary determinant of what tabs are available
final List<Map<String, dynamic>> tabConfigurations = [
  {
    'title': 'Pantry',
    'icon': Icons.kitchen_rounded,
    'screen':
        (title) => BaseScreen(
          itemType: lowercaseAndRemoveSpaces(title),
          boxName: lowercaseAndRemoveSpaces(title),
          title: title,
        ),
    'onFabPressed':
        (title) => AddItemScreen(
          onItemAdded: (ListItem dummy) => [],
          itemType: lowercaseAndRemoveSpaces(title),
          hasCount: true,
        ),
  },
  {
    'title': 'Shopping',
    'icon': Icons.local_grocery_store,
    'screen':
        (title) => BaseScreen(
          itemType: 'pantry', // Special case
          boxName: lowercaseAndRemoveSpaces(title),
          title: title,
          moveTo: 'pantry', // Special case
        ),
    'onFabPressed':
        (title) => AddItemScreen(
          onItemAdded: (ListItem dummy) => [],
          itemType: lowercaseAndRemoveSpaces(title),
          hasCount: true,
        ),
  },
  {
    'title': 'Meals',
    'icon': Icons.dinner_dining,
    'screen':
        (title) => SimpleListScreen(
          itemType: lowercaseAndRemoveSpaces(title),
          boxName: lowercaseAndRemoveSpaces(title),
          title: title,
        ),
    'onFabPressed':
        (title) => AddItemScreen(
          onItemAdded: (ListItem dummy) => [],
          itemType: lowercaseAndRemoveSpaces(title),
          hasCount: false,
        ),
  },
  {
    'title': 'To Do',
    'icon': Icons.list,
    'screen':
        (title) => SimpleListScreen(
          itemType: lowercaseAndRemoveSpaces(title),
          boxName: lowercaseAndRemoveSpaces(title),
          title: title,
        ),
    'onFabPressed':
        (title) => AddItemScreen(
          onItemAdded: (ListItem dummy) => [],
          itemType: lowercaseAndRemoveSpaces(title),
          hasCount: false,
        ),
  },
  {
    'title': 'To Eat',
    'icon': Icons.local_dining,
    'screen':
        (title) => SimpleListScreen(
          itemType: lowercaseAndRemoveSpaces(title),
          boxName: lowercaseAndRemoveSpaces(title),
          title: title,
        ),
    'onFabPressed':
        (title) => AddItemScreen(
          onItemAdded: (ListItem dummy) => [],
          itemType: 'meals', // Special case
          hasCount: false,
        ),
  },
];

Map<String, TabItem> tabItems = Map.fromEntries(
  tabConfigurations.map(
    (config) => MapEntry(
      lowercaseAndRemoveSpaces(config['title']),
      TabItem(
        screen: config['screen'](config['title']),
        icon: Icon(config['icon']),
        label: config['title'],
      ),
    ),
  ),
);

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

  static TextStyle buttonText = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    // color: secondaryColor,
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
