import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

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
  late Map<String, String?> currentLocations;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocations(); // Load the locations from Hive on init
  }

  // Load current locations from the Hive box
  void _loadCurrentLocations() {
    final settingsBox = Hive.box<Settings>('settings');
    final locations = <String, String?>{};

    // Retrieve all settings for each boxName and load fileLocation
    for (String boxName in boxNames) {
      final settings = settingsBox.get(boxName);
      locations[boxName] = settings?.fileLocation ?? 'Not set';
    }

    // Update the state with the loaded locations
    setState(() {
      currentLocations = locations;
    });
  }

  Future<String?> _pickDirectory() async {
    final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      fileExtensionsFilter: ['json'],
    );

    final filePath = await FlutterFileDialog.pickFile(params: params);
    return filePath;
  }

  Future<void> setFileLocation(String boxName, String? fileLocation) async {
    var settingsBox = Hive.box<Settings>('settings');
    var settings = settingsBox.get(boxName);

    if (settings == null) {
      // If settings are not found, create a new Settings object
      settings = Settings(boxName: boxName, fileLocation: fileLocation);
      await settingsBox.add(settings);
    } else {
      settings.fileLocation = fileLocation; // Uses setter
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
                    Text('File locations (if sync desired)', style: TextStyles.buttonText),
                    ...currentLocations.entries.map((entry) {
                      final boxName = entry.key;
                      final fileLocation = entry.value ?? 'Not set';

                      return ListTile(
                        title: FileLocationWidget(boxName: boxName, fileLocation: fileLocation),
                        trailing: IconButton(
                          // Folder at the end
                          icon: Icon(Icons.folder_open),
                          onPressed: () async {
                            String? selectedLocation = await _pickDirectory();
                            if (selectedLocation != null) {
                              setState(() {
                                currentLocations[boxName] = selectedLocation;
                              });
                              await setFileLocation(boxName, selectedLocation);
                            }
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
