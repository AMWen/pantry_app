import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/classes/box_settings.dart';
import '../data/classes/list_item.dart';
import '../data/classes/tab_configuration.dart';
import '../data/classes/tab_item.dart';
import '../data/constants.dart';
import '../screens/list_screen.dart';

Future<void> initializeHiveBoxes() async {
  await Hive.openBox<TabConfiguration>(HiveBoxNames.tabConfigurations);
  await initializeTabConfigurations();
  List<String> boxNames = getBoxNames();
  await Hive.openBox<BoxSettings>(HiveBoxNames.boxSettings);
  await initializeBoxSettings(boxNames);
  await Future.wait(boxNames.map((boxName) => openBox(boxName)).toList());
}

Future<void> openBox(String boxName) async {
  await Hive.openBox<ListItem>(boxName);
}

Box<TabConfiguration> getTabConfigurationsBox() {
  return Hive.box<TabConfiguration>(HiveBoxNames.tabConfigurations);
}

Future<void> initializeTabConfigurations() async {
  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  if (tabBox.isEmpty) {
    for (var config in defaultTabConfigurations) {
      // Use boxName as key
      await tabBox.put(lowercaseAndRemoveSpaces(config.title), config);
    }
  }
}

Map<String, String> getBoxNameToTitleMap() {
  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  return {for (var config in tabBox.values) config.key: config.title};
}

Box<BoxSettings> getBoxSettingsBox() {
  return Hive.box<BoxSettings>(HiveBoxNames.boxSettings);
}

Future<void> initializeBoxSettings(List<String> boxNames) async {
  var settingsBox = getBoxSettingsBox();

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
  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  return tabBox.values.map((config) {
    final boxName = lowercaseAndRemoveSpaces(config.title);
    return boxName;
  }).toList();
}

IconData getMaterialIcon(int iconCodePoint) {
  return IconData(iconCodePoint, fontFamily: 'MaterialIcons');
}

List<TabConfiguration> generateTabConfigs() {
  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  List<TabConfiguration> tabConfigs = tabBox.values.toList();

  tabConfigs.sort((a, b) => a.sort.compareTo(b.sort));

  // Re-index sorting
  for (int index = 0; index < tabConfigs.length; index++) {
    tabConfigs[index].sort = index;
  }
  return tabConfigs;
}

List<TabItem> generateTabItems(ValueNotifier<int> refreshNotifier) {
  List<TabConfiguration> tabConfigs = generateTabConfigs();
  return tabConfigs.map((config) {
    final iconData = getMaterialIcon(config.iconCodePoint);
    final boxName = lowercaseAndRemoveSpaces(config.title);
    final screen = ListScreen(
      itemType: config.itemType,
      boxName: boxName,
      title: config.title,
      refreshNotifier: refreshNotifier,
    );

    return TabItem(
      screen: screen,
      icon: Icon(iconData),
      label: config.title,
      itemType: config.itemType,
      boxName: boxName,
    );
  }).toList();
}
