import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:hive/hive.dart';

import '../data/classes/list_item.dart';

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
      return 'Items imported successfully!';
    } else {
      return 'No file path provided';
    }
  } catch (e) {
    return 'Error importing items: $e';
  }
}

Future<String> exportItemsToFile(String? filePath, List<ListItem> listItems) async {
  try {
    if (listItems.isNotEmpty) {
      final jsonList = listItems.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);

      if (filePath != null) {
        final file = File(filePath);
        await file.writeAsString(jsonString);
      }
      return 'Items exported successfully!';
    } else {
      return 'No items to export!';
    }
  } catch (e) {
    return 'Error exporting items: $e';
  }
}
