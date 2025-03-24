import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import '../../utils/file_utils.dart';
import '../classes/list_item.dart';
import '../classes/settings.dart';
import '../constants.dart';
import 'basic_widgets.dart';
import 'filelocation_widget.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  SettingsDialogState createState() => SettingsDialogState();
}

class SettingsDialogState extends State<SettingsDialog> {
  Map<String, String?> currentLocations = {};
  late Box<Settings> _settingsBox;
  bool _showHelpText = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box<Settings>(settings);
    for (String boxName in boxNames) {
      final settings = _settingsBox.get(boxName);
      currentLocations[boxName] = settings?.fileLocation ?? 'Not set';
    }
  }

  Future<bool?> _showOverwriteDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AlertTitle('Initial Sync'),
          content: Text(
            "Do you want to save the current list to the file or overwrite it with the file's data?",
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(false); // should(Not)Overwrite
              },
              child: Text('Save'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true); // shouldOverwrite
              },
              child: Text('Overwrite'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLocationSelection(String boxName) async {
    String? selectedLocation = await pickDirectory();
    if (selectedLocation != null) {
      setState(() {
        currentLocations[boxName] = selectedLocation;
      });
      await setFileLocation(boxName, selectedLocation);

      // Decision: how to sync?
      bool? shouldOverwrite = await _showOverwriteDialog();
      if (shouldOverwrite == true) {
        await importItemsFromFile(selectedLocation, boxName, add: false);
      } else if (shouldOverwrite == false) {
        var itemBox = Hive.box<ListItem>(boxName);
        await exportItemsToFile(selectedLocation, itemBox.values.toList());
      }
    }
  }

  Future<void> setFileLocation(String boxName, String? fileLocation) async {
    var boxSettings = _settingsBox.get(boxName);

    if (boxSettings == null) {
      // If settings are not found, create a new Settings object
      boxSettings = Settings(boxName: boxName, fileLocation: fileLocation);
      await _settingsBox.add(boxSettings);
    } else {
      boxSettings.fileLocation = fileLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AlertTitle('Sync Settings'),
      content:
          currentLocations.isEmpty
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading while locations are being loaded
              : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showHelpText = !_showHelpText;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('File locations (if sync desired)', style: TextStyles.boldText),
                          Text('Click for tips', style: TextStyles.tagText),
                        ],
                      ),
                    ),
                    if (_showHelpText)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '- Click filepaths to expand. They are scrollable.\n'
                          '- Filepaths need to be an existing file.\n'
                          '- If no file exists yet, save the current list first.\n'
                          '- New changes will get automatically saved.\n'
                          '- Likewise, any updates to the file will overwrite current list.',
                          style: TextStyles.tagText,
                        ),
                      ),
                    ...currentLocations.entries.map((entry) {
                      final boxName = entry.key;
                      final fileLocation = entry.value ?? 'Not set';

                      return ListTile(
                        title: FileLocationWidget(boxName: boxName, fileLocation: fileLocation),
                        trailing: IconButton(
                          // Folder at the end
                          icon: Icon(Icons.folder_open),
                          onPressed: () {
                            _handleLocationSelection(boxName);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
