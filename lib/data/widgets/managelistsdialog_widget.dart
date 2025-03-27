import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:hive/hive.dart';

import '../../utils/hivebox_utils.dart';
import '../../utils/widget_utils.dart';
import '../classes/box_settings.dart';
import '../classes/tab_configuration.dart';
import '../classes/tab_item.dart';
import '../constants.dart';
import '../widgets/basic_widgets.dart';

class ManageListsDialog extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;

  const ManageListsDialog({super.key, required this.refreshNotifier});

  @override
  ManageListsDialogState createState() => ManageListsDialogState();
}

class ManageListsDialogState extends State<ManageListsDialog> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool?> _resetLists() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Are you sure you want to reset lists to default?'),
          content: Text('Any new lists will be removed. This action cannot be undone.'),
          actions: [
            CancelButton(),
            OkButton(
              onPressed: () async {
                Box<TabConfiguration> tabBox = getTabConfigurationsBox();
                Navigator.of(context).pop(true);
                await tabBox.deleteAll(tabBox.keys);
                await initializeTabConfigurations();
                widget.refreshNotifier.value++;
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditListDialog(String boxName) {
    Box<TabConfiguration> tabBox = getTabConfigurationsBox();
    TabConfiguration tab = tabBox.get(boxName)!;
    Box<BoxSettings> boxSettingsBox = getBoxSettingsBox();
    BoxSettings currentBoxSettings = boxSettingsBox.get(boxName)!;
    final tagsController = TextEditingController(text: currentBoxSettings.tags.join(', '));
    final ValueNotifier<bool> hasCountNotifier = ValueNotifier(tab.hasCount);
    final ValueNotifier<int> iconCodePointNotifier = ValueNotifier<int>(tab.iconCodePoint);
    final ValueNotifier<String?> moveToDropdownNotifier = ValueNotifier<String?>(null);

    Map<String, String> boxNameToTitleMap = {
      for (var config in tabBox.values) config.key: config.title,
    };
    List<String?> moveToOptions = (boxNameToTitleMap.keys.cast<String?>().toList()..add(null));
    if (moveToOptions.contains(tab.moveTo)) {
      moveToDropdownNotifier.value = tab.moveTo;
    }

    void pickIcon() async {
      IconPickerIcon? icon = await showIconPicker(
        context,
        configuration: SinglePickerConfiguration(
          searchHintText: 'eg. savings=pig',
          title: Text('Pick an icon (material icons)', style: TextStyles.dialogTitle),
        ),
      );

      if (icon != null) {
        setState(() {
          iconCodePointNotifier.value = icon.data.codePoint;
          tab.iconCodePoint = iconCodePointNotifier.value;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Edit ${tab.title}'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Title:', style: TextStyles.boldText),
                      SizedBox(width: 6),
                      Text(tab.title),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Countable:', style: TextStyles.boldText),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            hasCountNotifier.value = !hasCountNotifier.value;
                            tab.hasCount = hasCountNotifier.value;
                          });
                        },
                        child: ValueListenableBuilder<bool>(
                          valueListenable: hasCountNotifier,
                          builder: (context, hasCount, child) {
                            return Text(
                              hasCount.toString(),
                              style: TextStyle(color: Colors.blueAccent),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Icon:', style: TextStyles.boldText),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: pickIcon,
                        child: ValueListenableBuilder<int>(
                          valueListenable: iconCodePointNotifier,
                          builder: (context, iconCodePoint, child) {
                            return Icon(getMaterialIcon(iconCodePoint));
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text('Move to:', style: TextStyles.boldText),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: moveToDropdownNotifier,
                          builder: (context, moveTo, child) {
                            return DropdownButton<String>(
                              underline: Container(),
                              style: TextStyles.normalText,
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              isDense: true,
                              value: moveTo,
                              onChanged: (String? newValue) {
                                moveToDropdownNotifier.value = newValue;
                                tab.moveTo = moveToDropdownNotifier.value;
                              },
                              items:
                                  moveToOptions.map<DropdownMenuItem<String>>((String? value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child:
                                          value != null
                                              ? Text(boxNameToTitleMap[value] ?? '(Unknown)')
                                              : Text('(null)'),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags:', style: TextStyles.boldText),
                      SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          style: TextStyles.normalText,
                          controller: tagsController,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Separate by commas',
                            hintStyle: TextStyles.hintText,
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CancelButton(),
            OkButton(
              onPressed: () async {
                // Prep tags
                final tags = tagsController.text.split(',').map((tag) => tag.trim()).toSet();
                final updatedTags = List<String>.from(tags.where((tag) => tag.isNotEmpty));
                updatedTags.add('');
                currentBoxSettings.tags = updatedTags;

                // Save boxes
                tab.save();
                currentBoxSettings.save();

                widget.refreshNotifier.value++;
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // remove previous _showEditDialog
                _showEditDialog(); // re-render
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Edit list(s)'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  generateTabItems(widget.refreshNotifier).map<Widget>((TabItem tabItem) {
                    return ListTile(
                      minTileHeight: 10,
                      leading: tabItem.icon,
                      title: Text(tabItem.label, style: TextStyles.mediumText),
                      onTap: () {
                        _showEditListDialog(tabItem.boxName);
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [OkButton()],
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController(text: '');
    final tagsController = TextEditingController(text: '');
    final List<String> itemTypes = List.from(defaultTagMapping.keys)..add('');
    final ValueNotifier<String> selectedTypeNotifier = ValueNotifier<String>('');
    final ValueNotifier<bool> hasCountNotifier = ValueNotifier(false);
    final ValueNotifier<int> iconCodePointNotifier = ValueNotifier<int>(defaultCodePoint);
    final ValueNotifier<String?> moveToDropdownNotifier = ValueNotifier<String?>(null);
    final Box<TabConfiguration> tabBox = getTabConfigurationsBox();

    Map<String, String> boxNameToTitleMap = {
      for (var config in tabBox.values) config.key: config.title,
    };
    List<String?> moveToOptions = (boxNameToTitleMap.keys.cast<String?>().toList()..add(null));

    void pickIcon() async {
      IconPickerIcon? icon = await showIconPicker(
        context,
        configuration: SinglePickerConfiguration(
          searchHintText: 'e.g. savings=pig',
          title: Text('Pick an icon (material icons)', style: TextStyles.dialogTitle),
        ),
      );

      if (icon != null) {
        setState(() {
          iconCodePointNotifier.value = icon.data.codePoint;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Add a list'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Title:', style: TextStyles.boldText),
                      SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          style: TextStyles.normalText,
                          controller: titleController,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Title for list',
                            hintStyle: TextStyles.hintText,
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Countable:', style: TextStyles.boldText),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            hasCountNotifier.value = !hasCountNotifier.value;
                          });
                        },
                        child: ValueListenableBuilder<bool>(
                          valueListenable: hasCountNotifier,
                          builder: (context, hasCount, child) {
                            return Text(
                              hasCount.toString(),
                              style: TextStyle(color: Colors.blueAccent),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Icon:', style: TextStyles.boldText),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: pickIcon,
                        child: ValueListenableBuilder<int>(
                          valueListenable: iconCodePointNotifier,
                          builder: (context, iconCodePoint, child) {
                            return Icon(getMaterialIcon(iconCodePoint));
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text('Move to:', style: TextStyles.boldText),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: moveToDropdownNotifier,
                          builder: (context, moveTo, child) {
                            return DropdownButton<String>(
                              underline: Container(),
                              style: TextStyles.normalText,
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              isDense: true,
                              value: moveTo,
                              onChanged: (String? newValue) {
                                moveToDropdownNotifier.value = newValue;
                              },
                              items:
                                  moveToOptions.map<DropdownMenuItem<String>>((String? value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child:
                                          value != null
                                              ? Text(boxNameToTitleMap[value] ?? '(Unknown)')
                                              : Text('(null)'),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text('Item Type:', style: TextStyles.boldText),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: selectedTypeNotifier,
                          builder: (context, selectedType, child) {
                            return DropdownButton<String>(
                              underline: Container(),
                              style: TextStyles.normalText,
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              isDense: true,
                              value: selectedType, // Value from ValueNotifier
                              onChanged: (String? newValue) {
                                selectedTypeNotifier.value = newValue ?? ''; // Update ValueNotifier
                                if (newValue != null && defaultTagMapping.containsKey(newValue)) {
                                  tagsController.text = defaultTagMapping[newValue]!.join(', ');
                                }
                              },
                              items:
                                  itemTypes.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.isEmpty ? 'None: custom tags' : value),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags:', style: TextStyles.boldText),
                      SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          style: TextStyles.normalText,
                          controller: tagsController,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Separate by commas',
                            hintStyle: TextStyles.hintText,
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CancelButton(),
            OkButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String boxName = lowercaseAndRemoveSpaces(title);

                Box<TabConfiguration> tabBox = getTabConfigurationsBox();
                Box<BoxSettings> boxSettingsBox = getBoxSettingsBox();

                // Prep tags
                final tags = tagsController.text.split(',').map((tag) => tag.trim()).toSet();
                final updatedTags = List<String>.from(tags.where((tag) => tag.isNotEmpty));
                updatedTags.add('');

                TabConfiguration tabConfig = TabConfiguration(
                  title: title,
                  itemType: selectedTypeNotifier.value,
                  iconCodePoint: iconCodePointNotifier.value,
                  hasCount: hasCountNotifier.value,
                  moveTo: moveToDropdownNotifier.value,
                );
                BoxSettings boxSettings = BoxSettings(boxName: boxName, tags: updatedTags);
                Navigator.of(context).pop();

                await tabBox.put(boxName, tabConfig);
                await boxSettingsBox.put(boxName, boxSettings);
                await openBox(boxName);

                widget.refreshNotifier.value++;
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteList(String tabTitle) async {
    // Soft delete, only delete from tab configurations, not box settings and list items
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Are you sure you want to delete $tabTitle?'),
          content: Text('This action cannot be undone.'),
          actions: [
            CancelButton(),
            OkButton(
              onPressed: () async {
                Box<TabConfiguration> tabBox = getTabConfigurationsBox();
                tabBox.delete(tabTitle);
                widget.refreshNotifier.value++;
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // remove previous _showDeleteDialog
                await _showDeleteDialog(); // re-render
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Delete list(s)'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  generateTabItems(widget.refreshNotifier).map<Widget>((TabItem tabItem) {
                    return ListTile(
                      minTileHeight: 10,
                      leading: tabItem.icon,
                      title: Text(tabItem.label, style: TextStyles.mediumText),
                      onTap: () {
                        if (generateTabItems(widget.refreshNotifier).length > 1) {
                          _deleteList(tabItem.boxName);
                        } else {
                          showErrorSnackbar(context, 'Need to keep at least one list.');
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [OkButton()],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: alertPadding,
      title: AlertTitle('Manage Lists'),
      content: SingleChildScrollView(
        child: Column(
          children: generateListTiles(context, [
            {
              'leading': Icon(Icons.add),
              'title': 'Add a list',
              'action': () async => await _showAddDialog(),
            },
            {
              'leading': Icon(Icons.remove),
              'title': 'Delete list(s)',
              'action': () async => await _showDeleteDialog(),
            },
            {
              'leading': Icon(Icons.edit),
              'title': 'Edit list(s)',
              'action': () async => await _showEditDialog(),
            },
            {
              'leading': Icon(Icons.restore),
              'title': 'Reset lists to default',
              'action': () async {
                bool? result = await _resetLists();
                if (mounted && result == true) {
                  showErrorSnackbar(context, 'Lists have been reset!');
                }
              },
            },
          ], false),
        ),
      ),
      actions: [OkButton()],
    );
  }
}
