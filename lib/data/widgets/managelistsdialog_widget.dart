import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
// https://github.com/Ahmadre/FlutterIconPicker/blob/master/assets/generated_packs/FontAwesome.dart
import 'package:hive_flutter/hive_flutter.dart';

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
                await initializeHiveBoxes();
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
    final ValueNotifier<Map<String, dynamic>> iconDataNotifier =
        ValueNotifier<Map<String, dynamic>>(tab.iconData);
    final ValueNotifier<String?> moveToDropdownNotifier = ValueNotifier<String?>(null);

    Map<String, String> boxNameToTitleMap = getBoxNameToTitleMap();
    List<String?> moveToOptions = (boxNameToTitleMap.keys.cast<String?>().toList()..add(null));
    if (moveToOptions.contains(tab.moveTo)) {
      moveToDropdownNotifier.value = tab.moveTo;
    }

    void pickIcon() async {
      IconPickerIcon? icon = await showIconPicker(
        context,
        configuration: SinglePickerConfiguration(
          iconPackModes: [IconPack.fontAwesomeIcons, IconPack.material],
          title: Text('Pick an icon', style: TextStyles.dialogTitle),
        ),
      );

      if (icon != null) {
        setState(() {
          iconDataNotifier.value = {
            IconDataInfo.iconCodePoint: icon.data.codePoint,
            IconDataInfo.fontFamily: icon.data.fontFamily,
            IconDataInfo.fontPackage: icon.data.fontPackage,
          };
          tab.iconData = iconDataNotifier.value;
          showErrorSnackbar(context, 'Selected ${icon.name}!');
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
                        child: ValueListenableBuilder<Map>(
                          valueListenable: iconDataNotifier,
                          builder: (context, iconData, child) {
                            return Icon(
                              getIcon(
                                iconData[IconDataInfo.iconCodePoint],
                                iconData[IconDataInfo.fontFamily],
                                iconData[IconDataInfo.fontPackage],
                              ),
                              color: Theme.of(context).textTheme.bodyMedium!.color,
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
                        child: Text('Move to:', style: TextStyles.boldText),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: moveToDropdownNotifier,
                          builder: (context, moveTo, child) {
                            return DropdownButton<String>(
                              underline: Container(),
                              style: TextStyles.normalText.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
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

  void _onReorder(int oldIndex, int newIndex) {
    List<TabConfiguration> tabs = generateTabConfigs();
    int dropIndex = newIndex;
    if (oldIndex < newIndex) {
      dropIndex = newIndex - 1; // strange, but 0 <-> 1 gives 0,2 vs 1,0 depending on drag direction
    }

    final moveItem = tabs.removeAt(oldIndex);
    tabs.insert(dropIndex, moveItem);

    for (int i = 0; i < tabs.length; i++) {
      tabs[i].sort = i;
      tabs[i].save();
    }

    widget.refreshNotifier.value++;
  }

  Future<void> _showEditDialog() async {
    Box<TabConfiguration> tabBox = Hive.box<TabConfiguration>(HiveBoxNames.tabConfigurations);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
          valueListenable: tabBox.listenable(),
          builder: (context, Box<TabConfiguration> box, _) {
            List<TabConfiguration> tabs = generateTabConfigs();

            return AlertDialog(
              contentPadding: alertPadding,
              title: AlertTitle('Edit list(s)'),
              content: SizedBox(
                width: double.maxFinite > 400 ? 400 : double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      onReorder: _onReorder,
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final tabItem = tabs[index];
                        return ListTile(
                          key: ValueKey(tabItem.key),
                          minTileHeight: 10,
                          leading: Icon(
                            getIcon(
                              tabItem.iconData[IconDataInfo.iconCodePoint],
                              tabItem.iconData[IconDataInfo.fontFamily],
                              tabItem.iconData[IconDataInfo.fontPackage],
                            ),
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          title: Text(tabItem.title, style: TextStyles.mediumText),
                          onTap: () {
                            _showEditListDialog(tabItem.key);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_indicator),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (generateTabItems(widget.refreshNotifier).length > 1) {
                                    _deleteList(tabItem.key);
                                  } else {
                                    showErrorSnackbar(context, 'Need to keep at least one list.');
                                  }
                                },
                                child: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [OkButton()],
            );
          },
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
    final ValueNotifier<Map<String, dynamic>> iconDataNotifier =
        ValueNotifier<Map<String, dynamic>>(defaultIconData);
    final ValueNotifier<String?> moveToDropdownNotifier = ValueNotifier<String?>(null);

    Map<String, String> boxNameToTitleMap = getBoxNameToTitleMap();
    List<String?> moveToOptions = (boxNameToTitleMap.keys.cast<String?>().toList()..add(null));

    void pickIcon() async {
      IconPickerIcon? icon = await showIconPicker(
        context,
        configuration: SinglePickerConfiguration(
          iconPackModes: [IconPack.fontAwesomeIcons, IconPack.material],
          title: Text('Pick an icon', style: TextStyles.dialogTitle),
        ),
      );

      if (icon != null) {
        setState(() {
          iconDataNotifier.value = {
            IconDataInfo.iconCodePoint: icon.data.codePoint,
            IconDataInfo.fontFamily: icon.data.fontFamily,
            IconDataInfo.fontPackage: icon.data.fontPackage,
          };
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
                            hintText: 'Unique title for list',
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
                        child: ValueListenableBuilder<Map>(
                          valueListenable: iconDataNotifier,
                          builder: (context, iconData, child) {
                            return Icon(
                              getIcon(
                                iconData[IconDataInfo.iconCodePoint],
                                iconData[IconDataInfo.fontFamily],
                                defaultFontPackage,
                                //iconData[IconDataInfo.fontPackage],
                              ),
                              color: Theme.of(context).textTheme.bodyMedium!.color,
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
                        child: Text('Move to:', style: TextStyles.boldText),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: moveToDropdownNotifier,
                          builder: (context, moveTo, child) {
                            return DropdownButton<String>(
                              underline: Container(),
                              style: TextStyles.normalText.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
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
                              style: TextStyles.normalText.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
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
                  iconData: iconDataNotifier.value,
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
          title: AlertTitle('Are you sure you want to delete ${getBoxNameToTitleMap()[tabTitle]}?'),
          content: Text('This action cannot be undone.'),
          actions: [
            CancelButton(),
            OkButton(
              onPressed: () async {
                Box<TabConfiguration> tabBox = getTabConfigurationsBox();
                tabBox.delete(tabTitle);
                widget.refreshNotifier.value++;
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // remove previous _showEditDialog
                await _showEditDialog(); // re-render
              },
            ),
          ],
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
