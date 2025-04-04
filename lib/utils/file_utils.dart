import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

import '../data/classes/list_item.dart';
import '../data/classes/box_settings.dart';
import '../data/classes/tab_configuration.dart';
import '../data/constants.dart';
import 'hivebox_utils.dart';

String importSuccess = 'Items imported successfully!';
String exportSuccess = 'Items exported successfully!';

void setLastUpdated(String boxName) {
  Box<BoxSettings> settingsBox = getBoxSettingsBox();
  final BoxSettings boxBoxSettings = settingsBox.get(boxName)!;
  boxBoxSettings.lastUpdated = DateTime.now();
}

Future<String> saveItemsWithSaveDialog(String fileName, List<ListItem> listItems) async {
  try {
    final jsonList = listItems.map((item) => item.toJson()).toList();
    final jsonString = json.encode(jsonList);

    await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(jsonString.codeUnits),
    ); // bug where filePath returned defaults to downloads folder

    return exportSuccess;
  } catch (e) {
    return 'Error exporting items: $e';
  }
}

Future<String?> pickLocation() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  final filePath = result?.files.first.path;
  return filePath;
}

Future<String> loadItemsFromFile(String? filePath, String boxName, {bool add = true}) async {
  Box<ListItem> itemBox = Hive.box<ListItem>(boxName);

  try {
    if (filePath != null) {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      if (add == false) {
        // itemBox.clear();
        final keys = itemBox.keys.toList();
        await itemBox.deleteAll(keys);
      }

      for (var itemData in jsonList) {
        final listItem = ListItem.fromJson(itemData);
        itemBox.add(listItem);
      }

      setLastUpdated(boxName);
      return importSuccess;
    } else {
      return 'No file path provided';
    }
  } catch (e) {
    return 'Error importing items: $e';
  }
}

Future<String> saveItemsToFile(String? filePath, List<ListItem> listItems) async {
  try {
    final jsonList = listItems.map((item) => item.toJson()).toList();
    final jsonString = json.encode(jsonList);

    if (filePath != null) {
      final file = File(filePath);
      await file.writeAsString(jsonString);
      return exportSuccess;
    } else {
      return 'Error: No file path provided';
    }
  } catch (e) {
    return 'Error exporting items: $e';
  }
}

Future<String?> autoLoad(String boxName, {Function(String)? showErrorSnackbar}) async {
  Box<BoxSettings> settingsBox = getBoxSettingsBox();
  final BoxSettings? boxBoxSettings = settingsBox.get(boxName);
  final String? filePath = boxBoxSettings?.syncLocation;

  if (filePath != null && boxBoxSettings != null) {
    try {
      final file = File(filePath);
      bool fileExists = await file.exists();

      if (fileExists) {
        final lastModified = await file.lastModified();
        final lastUpdated = boxBoxSettings.lastUpdated;

        if (lastUpdated != null && lastUpdated.isBefore(lastModified)) {
          String message = await loadItemsFromFile(filePath, boxName, add: false);

          if (message == importSuccess) {
            boxBoxSettings.lastUpdated = lastModified;
            if (showErrorSnackbar != null) {
              showErrorSnackbar(message);
            }
          }

          return message;
        } else {
          return 'List is up-to-date.';
        }
      } else {
        return 'File does not exist.';
      }
    } catch (e) {
      return 'Error checking file: $e';
    }
  } else {
    return null;
  }
}

Future<String?> autoSave(String boxName) async {
  Box<BoxSettings> settingsBox = getBoxSettingsBox();
  Box<ListItem> itemBox = Hive.box<ListItem>(boxName);
  final BoxSettings? boxBoxSettings = settingsBox.get(boxName);
  final String? filePath = boxBoxSettings?.syncLocation;

  if (filePath != null && boxBoxSettings != null) {
    try {
      final file = File(filePath);
      bool fileExists = await file.exists();
      if (fileExists) {
        final lastModified = await file.lastModified();
        final lastUpdated = boxBoxSettings.lastUpdated;

        if (lastUpdated != null && lastUpdated.isAfter(lastModified)) {
          String message = await saveItemsToFile(filePath, itemBox.values.toList());

          if (message == exportSuccess) {
            final newLastModified = await file.lastModified();
            boxBoxSettings.lastUpdated = newLastModified;
          }

          return message;
        } else {
          return 'File is already up-to-date.';
        }
      } else {
        // If the file does not exist, export items to a new file
        String message = await saveItemsToFile(filePath, itemBox.values.toList());
        return message;
      }
    } catch (e) {
      return 'Error checking file: $e';
    }
  } else {
    return null;
  }
}

Future<String> saveAllToFile(String fileName) async {
  try {
    Map<String, dynamic> allData = {};

    // All lists (one for each boxName)
    for (var boxName in getBoxNames()) {
      Box<ListItem> box = Hive.box<ListItem>(boxName);
      List<Map<String, dynamic>> boxData = box.values.map((item) => item.toJson()).toList();
      allData[boxName] = boxData;
    }

    // Settings (single one containing each boxName as a key)
    Box<BoxSettings> settingsBox = getBoxSettingsBox();
    List<Map<String, dynamic>> settingsBoxData =
        settingsBox.values.map((item) => item.toJson()).toList();
    allData[HiveBoxNames.boxSettings] = settingsBoxData;

    // Tab Configs (single one containing each boxName as a key)
    Box<TabConfiguration> tabBox = getTabConfigurationsBox();
    List<Map<String, dynamic>> tabBoxData = tabBox.values.map((item) => item.toJson()).toList();
    allData[HiveBoxNames.tabConfigurations] = tabBoxData;

    await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(json.encode(allData).codeUnits),
    );

    return 'Data exported successfully';
  } catch (e) {
    return 'Error exporting data: $e';
  }
}

Future<String> loadAllFromFile(String? filePath) async {
  try {
    if (filePath != null) {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> allData = json.decode(jsonString);

      // Get Settings and Tab Configurations first
      Box<BoxSettings> settingsBox = getBoxSettingsBox();
      await settingsBox.deleteAll(settingsBox.keys.toList());
      final List<dynamic> settings = allData[HiveBoxNames.boxSettings];
      for (var settingsData in settings) {
        final currentBoxSettings = BoxSettings.fromJson(settingsData);
        await settingsBox.put(currentBoxSettings.boxName, currentBoxSettings);
      }

      Box<TabConfiguration> tabBox = getTabConfigurationsBox();
      await tabBox.deleteAll(tabBox.keys.toList());
      final List<dynamic> configs = allData[HiveBoxNames.tabConfigurations];
      for (var config in configs) {
        final currentTab = TabConfiguration.fromJson(config);
        await tabBox.put(lowercaseAndRemoveSpaces(currentTab.title), currentTab);
      }

      // Process each box's data and load it into the corresponding box
      for (String boxName in allData.keys) {
        if (!{HiveBoxNames.tabConfigurations, HiveBoxNames.boxSettings}.contains(boxName)) {
          await Hive.openBox<ListItem>(boxName);
          Box<ListItem> box = Hive.box<ListItem>(boxName);
          await box.deleteAll(box.keys.toList());
          final List<dynamic> items = allData[boxName];
          for (var itemData in items) {
            final listItem = ListItem.fromJson(itemData);
            await box.add(listItem);
          }
        }
      }

      await initializeHiveBoxes();

      return 'Data imported successfully';
    } else {
      return 'No file path provided';
    }
  } catch (e) {
    return 'Error importing data: $e';
  }
}
