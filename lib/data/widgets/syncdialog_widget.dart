import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:pantry_app/data/widgets/snackbar_widget.dart';

import '../../utils/file_utils.dart';
import '../classes/list_item.dart';
import '../classes/settings.dart';
import '../constants.dart';
import 'basic_widgets.dart';
import 'filelocation_widget.dart';

class SyncDialog extends StatefulWidget {
  const SyncDialog({super.key});

  @override
  SyncDialogState createState() => SyncDialogState();
}

class SyncDialogState extends State<SyncDialog> {
  Map<String, String?> currentLocations = {};
  late Box<Settings> _settingsBox;
  bool _showHelpText = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box<Settings>(settings);
    for (String boxName in boxNames) {
      final boxSettings = _settingsBox.get(boxName);
      currentLocations[boxName] = boxSettings?.fileLocation ?? 'Not set';
    }
  }

  Future<bool?> _showOverwriteDialog(BuildContext context) async {
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

  Future<void> _handleLocationSelection(BuildContext context, boxName) async {
    String? selectedLocation = await pickLocation();
    if (selectedLocation != null) {
      setState(() {
        currentLocations[boxName] = selectedLocation;
      });
      await setFileLocation(boxName, selectedLocation);

      // Decision: how to sync?
      bool? shouldOverwrite = await _showOverwriteDialog(context);
      String? message;
      if (shouldOverwrite == true) {
        message = await loadItemsFromFile(selectedLocation, boxName, add: false);
      } else if (shouldOverwrite == false) {
        var itemBox = Hive.box<ListItem>(boxName);
        message = await saveItemsToFile(selectedLocation, itemBox.values.toList());
      }
      if (mounted && message != null) {
        showErrorSnackbar(context, message);
      }
    }
  }

  void _deleteLocationSelection(String boxName) async {
    setState(() {
      currentLocations[boxName] = null;
    });
    await setFileLocation(boxName, null);
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
                          Text('Click above for tips', style: TextStyles.tagText),
                        ],
                      ),
                    ),
                    if (_showHelpText)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '- This is a WIP. Use at your own risk.\n'
                          '- Click filepaths to expand. They are scrollable.\n'
                          '- Filepaths need to be an existing file.\n'
                          '- If no file exists yet, save the current list first.\n'
                          '- New changes will get automatically saved.\n'
                          '- File changes will be checked every 5 minutes and may overwrite the list.\n'
                          '- Not intended for real-time collaboration.',
                          style: TextStyles.tagText,
                        ),
                      ),
                    ...currentLocations.entries.map((entry) {
                      final boxName = entry.key;
                      final fileLocation = entry.value ?? 'Not set';

                      return Row(
                        children: [
                          SizedBox(width: 6),
                          Expanded(
                            child: FileLocationWidget(boxName: boxName, fileLocation: fileLocation),
                          ),
                          SizedBox(
                            width: 36,
                            child: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _handleLocationSelection(context, boxName);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteLocationSelection(boxName);
                              },
                            ),
                          ),
                        ],
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
