import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
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

Future<String> saveItemsAsCsv(String fileName, List<ListItem> listItems) async {
  try {
    List<List<String>> csvData = [
      ListItem.headers,
      ...listItems.map((item) => item.toCsv().split(',')),
    ];
    String csvString = const ListToCsvConverter().convert(csvData);

    await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: Uint8List.fromList(utf8.encode(csvString)),
    );

    return exportSuccess;
  } catch (e) {
    return 'Error exporting items: $e';
  }
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

const allowedExtensions = ['json', 'csv'];
Future<String?> pickLocation([List<String> allowedExtensions = allowedExtensions]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
  );
  final filePath = result?.files.first.path;
  return filePath;
}

Future<String> loadItemsFromFile(String? filePath, String boxName, {bool add = true}) async {
  Box<ListItem> itemBox = Hive.box<ListItem>(boxName);

  try {
    if (filePath != null) {
      final file = File(filePath);
      final fileExtension = filePath.split('.').last.toLowerCase();
      List<ListItem> listItems;

      final fileString = await file.readAsString();
      if (fileExtension == 'json') {
        final List<dynamic> jsonList = json.decode(fileString);
        listItems = jsonList.map((itemData) => ListItem.fromJson(itemData)).toList();
      } else if (fileExtension == 'csv') {
        listItems = parseCsvToItems(fileString, ListItem).cast<ListItem>();
      } else {
        return 'Unsupported file type. Please provide a JSON or CSV file.';
      }

      if (add == false) {
        final keys = itemBox.keys.toList();
        await itemBox.deleteAll(keys);
      }

      for (var listItem in listItems) {
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

Future<String> saveAllToXlsx(String fileName) async {
  try {
    var excel = Excel.createExcel();

    // Add data for each boxName in different sheets
    for (var boxName in getBoxNames()) {
      var sheet = excel[boxName];
      Box<ListItem> box = Hive.box<ListItem>(boxName);
      sheet.appendRow(ListItem.headers.map((e) => TextCellValue(e)).toList());
      for (var item in box.values) {
        sheet.appendRow(item.toCsv().split(',').map((e) => TextCellValue(e)).toList());
      }
    }

    // Add settings to a separate sheet
    var settingsSheet = excel[HiveBoxNames.boxSettings];
    Box<BoxSettings> settingsBox = getBoxSettingsBox();
    settingsSheet.appendRow(BoxSettings.headers.map((e) => TextCellValue(e)).toList());
    for (var item in settingsBox.values) {
      settingsSheet.appendRow(item.toCsv().split(',').map((e) => TextCellValue(e)).toList());
    }

    // Add tab configurations to a separate sheet
    var tabConfigSheet = excel[HiveBoxNames.tabConfigurations];
    Box<TabConfiguration> tabBox = getTabConfigurationsBox();
    tabConfigSheet.appendRow(TabConfiguration.headers.map((e) => TextCellValue(e)).toList());
    for (var item in tabBox.values) {
      tabConfigSheet.appendRow(item.toCsv().split(',').map((e) => TextCellValue(e)).toList());
    }

    excel.delete('Sheet1');
    var fileBytes = excel.save();
    await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(fileBytes ?? []),
    );

    return 'Data exported successfully';
  } catch (e) {
    return 'Error exporting data: $e';
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
      final fileExtension = filePath.split('.').last.toLowerCase();

      if (fileExtension == 'json') {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> allData = json.decode(jsonString);
        await processJsonData(allData);
      } else if (fileExtension == 'xlsx') {
        var file = File(filePath);
        var bytes = await file.readAsBytes();
        var excel = Excel.decodeBytes(bytes);
        await processXlsxData(excel);
      } else {
        return 'Unsupported file type. Please provide a JSON or CSV file.';
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

Future<void> processJsonData(Map<String, dynamic> allData) async {
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
}

Future<void> processXlsxData(Excel excel) async {
  // Get Settings and Tab Configurations first
  Box<BoxSettings> settingsBox = getBoxSettingsBox();
  await settingsBox.deleteAll(settingsBox.keys.toList());
  Sheet? settingsSheet = excel.tables[HiveBoxNames.boxSettings];
  if (settingsSheet != null) {
    List<BoxSettings> settings = parseSheetToItems(settingsSheet, BoxSettings).cast<BoxSettings>();
    for (var currentBoxSettings in settings) {
      await settingsBox.put(currentBoxSettings.boxName, currentBoxSettings);
    }
  }

  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  await tabBox.deleteAll(tabBox.keys.toList());
  Sheet? configsSheet = excel.tables[HiveBoxNames.tabConfigurations];
  if (configsSheet != null) {
    final List<TabConfiguration> configs =
        parseSheetToItems(configsSheet, TabConfiguration).cast<TabConfiguration>();
    for (var currentTab in configs) {
      await tabBox.put(lowercaseAndRemoveSpaces(currentTab.title), currentTab);
    }
  }

  // Process each box's data and load it into the corresponding box
  for (String boxName in excel.tables.keys) {
    if (!{HiveBoxNames.tabConfigurations, HiveBoxNames.boxSettings}.contains(boxName)) {
      await Hive.openBox<ListItem>(boxName);
      Box<ListItem> box = Hive.box<ListItem>(boxName);
      await box.deleteAll(box.keys.toList());
      Sheet? sheet = excel.tables[boxName];
      if (sheet != null) {
        final List<ListItem> items = parseSheetToItems(sheet, ListItem).cast<ListItem>();
        for (var itemData in items) {
          await box.add(itemData);
        }
      }
    }
  }
}

List<dynamic> parseCsvToItems(String csvString, Type type) {
  List<dynamic> parsedItems = [];

  // Get all rows, skipping header row
  final rows = LineSplitter.split(csvString).toList();
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    final columns = row.split(',');

    // Check the column count against the headers for the type
    if (columns.length == getHeadersForType(type).length) {
      if (type == ListItem) {
        parsedItems.add(ListItem.parseCsvRowToItem(columns));
      } else if (type == BoxSettings) {
        var currentItem = BoxSettings.parseCsvRowToItem(columns);
        parsedItems.add(currentItem);
      } else if (type == TabConfiguration) {
        parsedItems.add(TabConfiguration.parseCsvRowToItem(columns));
      }
    }
  }
  return parsedItems;
}

List<String> getHeadersForType(Type type) {
  if (type == ListItem) {
    return ListItem.headers;
  } else if (type == BoxSettings) {
    return BoxSettings.headers;
  } else if (type == TabConfiguration) {
    return TabConfiguration.headers;
  }
  return [];
}

List<dynamic> parseSheetToItems(Sheet sheet, Type type) {
  List<dynamic> parsedItems = [];
  for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
    var row = sheet.rows[rowIndex];
    List<String> csvRow = row.map((cell) => cell?.value?.toString() ?? '').toList();
    if (csvRow.length == getHeadersForType(type).length) {
      if (type == ListItem) {
        parsedItems.add(ListItem.parseCsvRowToItem(csvRow));
      } else if (type == BoxSettings) {
        parsedItems.add(BoxSettings.parseCsvRowToItem(csvRow));
      } else if (type == TabConfiguration) {
        var currentItem = TabConfiguration.parseCsvRowToItem(csvRow);
        parsedItems.add(currentItem);
      }
    }
  }

  return parsedItems;
}
