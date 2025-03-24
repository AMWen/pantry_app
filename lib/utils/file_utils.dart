import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:hive/hive.dart';

import '../data/classes/list_item.dart';
import '../data/classes/settings.dart';
import '../data/constants.dart';

String importSuccess = 'Items imported successfully!';
String exportSuccess = 'Items exported successfully!';

void setLastUpdated(String boxName) {
  Box<Settings> settingsBox = Hive.box<Settings>(settings);
  final Settings boxSettings = settingsBox.get(boxName)!;
  boxSettings.lastUpdated = DateTime.now();
}

Future<String?> getSaveDirectory(String fileName) async {
  final params = SaveFileDialogParams(
    fileName: fileName,
    mimeTypesFilter: ['application/json'],
    data: Uint8List.fromList('{}'.codeUnits),
  );

  final filePath = await FlutterFileDialog.saveFile(params: params);
  return filePath;
}

Future<String?> pickDirectory() async {
  final params = OpenFileDialogParams(
    dialogType: OpenFileDialogType.document,
    fileExtensionsFilter: ['json'],
  );

  final filePath = await FlutterFileDialog.pickFile(params: params);
  return filePath;
}

Future<String> importItemsFromFile(String? filePath, String boxName, {bool add = true}) async {
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

Future<String> exportItemsToFile(String? filePath, List<ListItem> listItems) async {
  try {
    final jsonList = listItems.map((item) => item.toJson()).toList();
    final jsonString = json.encode(jsonList);

    if (filePath != null) {
      final file = File(filePath);
      await file.writeAsString(jsonString);
    }
    return exportSuccess;
  } catch (e) {
    return 'Error exporting items: $e';
  }
}

Future<String?> autoLoad(String boxName) async {
  Box<Settings> settingsBox = Hive.box<Settings>(settings);
  final Settings? boxSettings = settingsBox.get(boxName);
  final String? filePath = boxSettings?.fileLocation;

  if (filePath != null && boxSettings != null) {
    try {
      final file = File(filePath);
      bool fileExists = await file.exists();

      if (fileExists) {
        final lastModified = await file.lastModified();
        final lastUpdated = boxSettings.lastUpdated;

        if (lastUpdated != null && lastUpdated.isBefore(lastModified)) {
          String message = await importItemsFromFile(filePath, boxName, add: false);

          if (message == importSuccess) {
            boxSettings.lastUpdated = lastModified;
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
  Box<Settings> settingsBox = Hive.box<Settings>(settings);
  Box<ListItem> itemBox = Hive.box<ListItem>(boxName);
  final Settings? boxSettings = settingsBox.get(boxName);
  final String? filePath = boxSettings?.fileLocation;

  if (filePath != null && boxSettings != null) {
    try {
      final file = File(filePath);
      bool fileExists = await file.exists();
      if (fileExists) {
        final lastModified = await file.lastModified();
        final lastUpdated = boxSettings.lastUpdated;

        if (lastUpdated != null && lastUpdated.isAfter(lastModified)) {
          String message = await exportItemsToFile(filePath, itemBox.values.toList());

          print(message);
          if (message == exportSuccess) {
            final newLastModified = await file.lastModified();
            boxSettings.lastUpdated = newLastModified;
          }

          return message;
        } else {
          return 'File is already up-to-date.';
        }
      } else {
        // If the file does not exist, export items to a new file
        String message = await exportItemsToFile(filePath, itemBox.values.toList());
        return message;
      }
    } catch (e) {
      return 'Error checking file: $e';
    }
  } else {
    return null;
  }
}
