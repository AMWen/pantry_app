import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../screens/inventorylist_screen.dart';
import '../screens/simplelist_screen.dart';
import 'classes/tab_item.dart';

final String settings = 'settings';

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
    'boxName': (title) => lowercaseAndRemoveSpaces(title),
    'itemType': (boxName) => boxName,
    'icon': Icons.kitchen_rounded,
    'screen':
        (title, itemType, boxName) => InventoryListScreen(
          itemType: itemType,
          boxName: boxName,
          title: title,
          moveTo: 'shopping',
        ),
  },
  {
    'title': 'Shopping',
    'boxName': (title) => lowercaseAndRemoveSpaces(title),
    'itemType': 'pantry', // Special case
    'icon': Icons.local_grocery_store,
    'screen':
        (title, itemType, boxName) => InventoryListScreen(
          itemType: itemType,
          boxName: boxName,
          title: title,
          moveTo: 'pantry', // Special case
        ),
  },
  {
    'title': 'Meals',
    'boxName': (title) => lowercaseAndRemoveSpaces(title),
    'itemType': (boxName) => boxName,
    'icon': Icons.dinner_dining,
    'screen':
        (title, itemType, boxName) =>
            SimpleListScreen(itemType: itemType, boxName: boxName, title: title),
  },
  {
    'title': 'To Do',
    'boxName': (title) => lowercaseAndRemoveSpaces(title),
    'itemType': (boxName) => boxName,
    'icon': Icons.list,
    'screen':
        (title, itemType, boxName) =>
            SimpleListScreen(itemType: itemType, boxName: boxName, title: title),
  },
  {
    'title': 'To Eat',
    'boxName': (title) => lowercaseAndRemoveSpaces(title),
    'itemType': 'meals', // Special case
    'icon': Icons.local_dining,
    'screen':
        (title, itemType, boxName) =>
            SimpleListScreen(itemType: itemType, boxName: boxName, title: title),
  },
];

Map<String, TabItem> tabItems = Map.fromEntries(
  tabConfigurations.map((config) {
    final boxName = config['boxName'](config['title']);
    final itemType =
        config['itemType'] is Function ? config['itemType'](boxName) : config['itemType'];
    final screen = config['screen'](config['title'], itemType, boxName);

    return MapEntry(
      boxName, // boxName as the key
      TabItem(
        screen: screen,
        icon: Icon(config['icon']),
        label: config['title'], // Use title as the label
        itemType: itemType, // Set the itemType
        boxName: boxName, // Set the boxName
      ),
    );
  }),
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

  static const TextStyle hintText = TextStyle(
    color: Colors.grey,
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle normalText = TextStyle(fontWeight: FontWeight.normal, fontSize: 14);

  static const TextStyle boldText = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
}
