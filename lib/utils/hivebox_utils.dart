import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/classes/box_settings.dart';
import '../data/classes/list_item.dart';
import '../data/classes/tab_configuration.dart';
import '../data/classes/tab_item.dart';
import '../data/constants.dart';
import '../screens/inventorylist_screen.dart';
import '../screens/simplelist_screen.dart';

Future<void> initializeHiveBoxes() async {
  await Hive.openBox<TabConfiguration>(HiveBoxNames.tabConfigurations);
  await initializeTabConfigurations();
  List<String> boxNames = getBoxNames();
  await Hive.openBox<BoxSettings>(HiveBoxNames.boxSettings);
  await initializeBoxSettings(boxNames);
  await Future.wait(boxNames.map((boxName) => Hive.openBox<ListItem>(boxName)).toList());
}

Future<void> initializeTabConfigurations() async {
  Box<TabConfiguration> tabBox = Hive.box<TabConfiguration>(HiveBoxNames.tabConfigurations);
  if (tabBox.isEmpty) {
    for (var config in defaultTabConfigurations) {
      await tabBox.add(config);
    }
  }
}

Future<void> initializeBoxSettings(List<String> boxNames) async {
  var settingsBox = Hive.box<BoxSettings>(HiveBoxNames.boxSettings);

  // Initialize BoxSettings for each boxName
  for (String boxName in boxNames) {
    if (!settingsBox.containsKey(boxName)) {
      settingsBox.put(boxName, BoxSettings(boxName: boxName));
    }
    BoxSettings currentBoxSettings = settingsBox.get(boxName)!;

    // For backwards compatibility (if tags = [''], reset)
    if (currentBoxSettings.tags.length == 1 && currentBoxSettings.tags[0] == '') {
      currentBoxSettings.resetTags();
    }
  }
}

List<String> getBoxNames() {
  Box<TabConfiguration> tabBox = Hive.box<TabConfiguration>(HiveBoxNames.tabConfigurations);
  return tabBox.values.map((config) {
    final boxName = lowercaseAndRemoveSpaces(config.title);
    return boxName;
  }).toList();
}

List<TabItem> generateTabItems() {
  Box<TabConfiguration> tabBox = Hive.box<TabConfiguration>(HiveBoxNames.tabConfigurations);
  return tabBox.values.map((config) {
    final iconData = IconData(config.iconCodePoint, fontFamily: 'MaterialIcons');
    final boxName = lowercaseAndRemoveSpaces(config.title);
    final screen =
        config.hasCount
            ? InventoryListScreen(
              itemType: config.itemType,
              boxName: boxName,
              title: config.title,
              moveTo: config.moveTo,
            )
            : SimpleListScreen(itemType: config.itemType, boxName: boxName, title: config.title);

    return TabItem(
      screen: screen,
      icon: Icon(iconData),
      label: config.title,
      itemType: config.itemType,
      boxName: boxName,
    );
  }).toList();
}
