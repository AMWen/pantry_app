import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/classes/box_settings.dart';
import '../data/classes/list_item.dart';
import '../data/classes/tab_configuration.dart';
import '../data/constants.dart';
// import '../data/classes/autoloadservice.dart';
import '../data/widgets/basic_widgets.dart';
import '../data/widgets/editdialog_widget.dart';
import '../data/widgets/edittagsdialog_widget.dart';
import '../data/widgets/popupmenu_widget.dart';
import '../data/widgets/tagsdialog_widget.dart';
// import '../data/widgets/syncdialog_widget.dart';
import '../data/widgets/saveloaddialog_widget.dart';
import '../utils/file_utils.dart';
import '../utils/hivebox_utils.dart';
import '../utils/widget_utils.dart';

class ListScreen extends StatefulWidget {
  final String itemType;
  final String boxName; // Can be different (e.g. shopping box for pantry items)
  final String title;
  final ValueNotifier<int> refreshNotifier;

  const ListScreen({
    super.key,
    required this.itemType,
    required this.boxName,
    required this.title,
    required this.refreshNotifier,
  });

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  // late AutoLoadService _autoLoadService;
  late Box<ListItem> _itemBox;
  late List<String> _tagOrder;
  Set<int> _selectedItemIds = {};
  late BoxSettings currentBoxSettings;
  late TabConfiguration currentTab;
  List<ListItem> listItems = [];
  List<ListItem> completedItems = [];
  double updateQuantity = 0;

  @override
  void initState() {
    super.initState();
    initialize();
    // _autoLoadService = AutoLoadService();
    // Future.delayed(Duration.zero, () {
    //   if (mounted) {
    //     _autoLoadService.startAutoLoad(
    //       widget.boxName,
    //       showErrorSnackbar: (message) => showErrorSnackbar(context, message),
    //     );
    //   }
    // });
  }

  void initialize() async {
    currentTab = TabConfiguration(title: widget.title, itemType: widget.itemType);
    _itemBox = Hive.box<ListItem>(widget.boxName);

    Box<BoxSettings> boxSettingsBox = getBoxSettingsBox();
    if (!boxSettingsBox.keys.contains(widget.boxName)) {
      await initializeBoxSettings([widget.boxName]);
    }
    currentBoxSettings = boxSettingsBox.get(widget.boxName)!;

    Box<TabConfiguration> tabBox = getTabConfigurationsBox();
    if (!tabBox.keys.contains(widget.boxName)) {
      await initializeTabConfigurations(true);
      await Hive.openBox<ListItem>(widget.boxName);
    }
    currentTab = tabBox.get(widget.boxName)!;
    _tagOrder = currentBoxSettings.tags;
  }

  @override
  void dispose() {
    // _autoLoadService.stopAutoLoad();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    // Prepend "http://" if no protocol is provided
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    final Uri parsedUrl = Uri.parse(url);

    if (!await launchUrl(parsedUrl)) {
      if (mounted) {
        showErrorSnackbar(context, 'Could not launch $url');
      }
    }
  }

  void copySelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      final selectedItems =
          _itemBox.values
              .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
              .toList();

      final itemNames = selectedItems
          .map((item) => currentTab.hasCount ? '${item.count} ${item.name}' : item.name)
          .join('\n');

      Clipboard.setData(ClipboardData(text: itemNames)).then((_) {
        if (mounted) {
          showErrorSnackbar(context, 'Copied selected items to clipboard');
        }
      });
    } else {
      showErrorSnackbar(context, 'No items selected to copy!');
    }
  }

  void _setLastUpdatedAndSave(String boxName) async {
    setLastUpdated(boxName);
    // String? message = await autoSave(boxName);
    // if (message != null) {
    //   if (mounted) {
    //     showErrorSnackbar(context, message);
    //   }
    // }
  }

  void _updateItem(dynamic key, int newCount) {
    setState(() {
      final item = _itemBox.get(key);
      if (newCount == 0) {
        _deleteItem(key);
      } else if (item != null) {
        item.count = newCount;
        item.save(); // Save the updated item back to the box
      }
    });
  }

  void _showItemDetails(ListItem item) {
    String displayName =
        item.name.endsWith('s') && !item.name.contains(' ')
            ? item.name.substring(0, item.name.length - 1) // Remove trailing 's'
            : item.name;
    showDialog(
      context: context,
      builder: (context) {
        updateQuantity = item.count.toDouble();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: alertPadding,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center the content
                children: [
                  Text('${item.count} ${item.name}', style: TextStyles.dialogTitle),
                  Text(
                    'Date Added: ${DateFormat('M/d/yy').format(item.dateAdded)}', // Format the date
                    style: TextStyle(
                      color: Colors.grey, // Lighter font color
                      fontWeight: FontWeight.w300, // Lighter weight
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center the content
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.remove, size: 15), // Icon size
                            onPressed: () {
                              setState(() {
                                updateQuantity = (updateQuantity - 1).clamp(0.0, double.infinity);
                              });
                            },
                          ),
                        ),
                        Slider(
                          value: updateQuantity,
                          min: 0,
                          max: max(item.count.toDouble(), updateQuantity),
                          divisions: item.count,
                          label: '$updateQuantity',
                          onChanged: (double value) {
                            setState(() {
                              updateQuantity = value;
                            });
                          },
                        ),
                        SizedBox(
                          width: 20,
                          child: IconButton(
                            icon: Icon(Icons.add, size: 15),
                            onPressed: () {
                              setState(() {
                                updateQuantity = (updateQuantity + 1).clamp(0.0, double.infinity);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'New Quantity: ${updateQuantity.toInt()} $displayName(s)',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                          onPressed: () {
                            _updateItem(item.key, updateQuantity.toInt());
                            updateQuantity = 0;
                            Navigator.of(context).pop();
                          },
                          child: Text('Update Quantity'),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: primaryColor),
                          onPressed: () {
                            _deleteItem(item.key);
                            updateQuantity = 0;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteItem(dynamic key) {
    setState(() {
      _itemBox.delete(key);
    });
  }

  void _deleteSelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: alertPadding,
            title: AlertTitle('Are you sure you want to delete all selected items?'),
            content: Text('This action cannot be undone.'),
            actions: [
              CancelButton(),
              OkButton(
                onPressed: () {
                  final selectedItems =
                      _itemBox.values
                          .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
                          .toList();

                  for (var item in selectedItems) {
                    _deleteItem(item.key);
                  }
                  _selectedItemIds.clear();
                  _setLastUpdatedAndSave(widget.boxName);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showErrorSnackbar(context, 'No items selected for deletion!');
    }
  }

  Future<bool?> _showTaggingOptions() {
    if (_selectedItemIds.isNotEmpty) {
      final selectedItems =
          _itemBox.values
              .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
              .toList();

      return showDialog<bool>(
        context: context,
        builder: (context) {
          return TagsDialog(selectedItems: selectedItems, currentBoxSettings: currentBoxSettings);
        },
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return EditTagsDialog(currentBoxSettings: currentBoxSettings);
        },
      );
    }
  }

  void _sortListItems(String criteria) {
    setState(() {
      currentBoxSettings.sortCriteria = criteria;
      currentBoxSettings.save();
    });
  }

  // void _showSync() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SyncDialog();
  //     },
  //   );
  // }

  void _showSortingOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                sortOptions.map((option) {
                  return ListTile(
                    minTileHeight: 10,
                    title: Text(option['title']!, style: TextStyles.normalText),
                    onTap: () {
                      _sortListItems(option['value']!);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void onItemTapped(ListItem item) {
    if (currentTab.hasCount) {
      _showItemDetails(item);
    } else {
      item.completed = (item.completed ?? false) ? false : true;
      item.save();
    }
    _setLastUpdatedAndSave(widget.boxName);
  }

  void _showEditDialog(ListItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(item: item, boxName: widget.boxName, hasCount: currentTab.hasCount);
      },
    );
  }

  void _showSaveLoadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SaveLoadDialog(
          refreshNotifier: widget.refreshNotifier,
          boxName: widget.boxName,
          itemBox: _itemBox,
          selectedItemIds: _selectedItemIds,
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    int dropIndex = newIndex;
    if (oldIndex < newIndex) {
      dropIndex = newIndex - 1; // strange, but 0 <-> 1 gives 0,2 vs 1,0 depending on drag direction
    }
    final moveItem = listItems.removeAt(oldIndex);
    listItems.insert(dropIndex, moveItem);
    if (!currentBoxSettings.showCompleted) {
      listItems = [...listItems, ...completedItems];
    }

    List<int> selectedItemIndices = List<int>.from(
      listItems
          .asMap()
          .entries
          .where((entry) => _selectedItemIds.contains(entry.value.key))
          .map((entry) => entry.key),
    );
    _selectedItemIds.clear();
    for (int i = 0; i < listItems.length; i++) {
      // Create a new instance of ListItem to avoid same instance error
      // Note: putAt index different from key, but key (of that index) gets reused, effectively replacing old object
      final currentItem = listItems[i];
      final newItem = ListItem.fromJson(currentItem.toJson());
      _itemBox.putAt(i, newItem);
      if (selectedItemIndices.contains(i)) {
        _selectedItemIds.add(_itemBox.getAt(i)!.key); // new key
      }
    }

    setState(() {
      currentBoxSettings.sortCriteria = '';
      currentBoxSettings.save();
    });
    _setLastUpdatedAndSave(widget.boxName);
  }

  void toggleSelectAll() {
    setState(() {
      bool newValue = _itemBox.values.every((item) => _selectedItemIds.contains(item.key)) == false;

      if (newValue) {
        _selectedItemIds = _itemBox.values.fold<Set<int>>({}, (Set<int> selectedIds, item) {
          selectedIds.add(item.key);
          return selectedIds;
        });
      } else {
        _selectedItemIds.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> actionList = [
      if (!currentTab.hasCount) // Only add this action if hasCount is false
        {
          'icon':
              currentBoxSettings.selectAllCompleted
                  ? Icons.visibility_off
                  : currentBoxSettings.showCompleted
                  ? Icons.check_box
                  : Icons.visibility,
          'onPressed': () {
            setState(() {
              if (currentBoxSettings.selectAllCompleted) {
                currentBoxSettings.showCompleted = false;
                currentBoxSettings.selectAllCompleted = false;
                _selectedItemIds.clear();
              } else if (currentBoxSettings.showCompleted) {
                currentBoxSettings.showCompleted = true;
                currentBoxSettings.selectAllCompleted = true;
                _selectedItemIds = _itemBox.values.fold<Set<int>>({}, (Set<int> selectedIds, item) {
                  if (item.completed == true) {
                    selectedIds.add(item.key);
                  }
                  return selectedIds;
                });
              } else {
                currentBoxSettings.showCompleted = true;
                currentBoxSettings.selectAllCompleted = false;
                _selectedItemIds.clear();
              }
            });
          },
        },
      {
        'icon': Icons.copy,
        'onPressed': () {
          copySelectedItems();
        },
      },
      {
        'icon': Icons.swap_vert,
        'onPressed': () {
          _showSortingOptions();
        },
      },
      {
        'icon': Icons.save,
        'onPressed': () {
          _showSaveLoadDialog();
        },
      },
      {
        'icon': Icons.label,
        'onPressed': () async {
          bool? result = await _showTaggingOptions();
          if (result == true) {
            _selectedItemIds.clear();
            _tagOrder = currentBoxSettings.tags;
            _setLastUpdatedAndSave(widget.boxName);
          }
        },
      },
      {'icon': Icons.delete_forever, 'onPressed': _deleteSelectedItems},
      // {
      //   'icon': Icons.sync,
      //   'onPressed': () {
      //     _showSync();
      //   },
      // },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...actionList.map(
            (action) => SizedBox(
              width: 34,
              child: IconButton(icon: Icon(action['icon']), onPressed: action['onPressed']),
            ),
          ),
          PopupMenu(
            refreshNotifier: widget.refreshNotifier,
            boxName: widget.boxName,
            itemBox: _itemBox,
            selectedItemIds: _selectedItemIds,
          ),
          Padding(padding: const EdgeInsets.only(right: 4)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
        child: ValueListenableBuilder<int>(
          valueListenable: widget.refreshNotifier,
          builder: (context, refreshValue, _) {
            initialize();
            return ValueListenableBuilder(
              valueListenable: _itemBox.listenable(),
              builder: (context, Box<ListItem> box, _) {
                if (box.values.isEmpty) {
                  return Center(child: Text('No items added yet.'));
                }

                listItems = box.values.toList(); // Original list
                completedItems = listItems.where((item) => item.completed == true).toList();

                // Filter out completed items
                if (!currentBoxSettings.showCompleted) {
                  listItems =
                      listItems
                          .where((item) => item.completed == false || item.completed == null)
                          .toList();
                }

                // Sort the items based on selected criteria
                if (currentBoxSettings.sortCriteria == 'name') {
                  listItems.sort((a, b) => a.name.compareTo(b.name));
                } else if (currentBoxSettings.sortCriteria == 'dateAdded') {
                  listItems.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
                } else if (currentBoxSettings.sortCriteria == 'tag') {
                  listItems.sort((a, b) {
                    int aIndex = _tagOrder.indexOf(a.tag ?? '');
                    int bIndex = _tagOrder.indexOf(b.tag ?? '');
                    return aIndex.compareTo(bIndex);
                  });
                }

                return Column(
                  children: [
                    // "Select All" checkbox row
                    ListTile(
                      key: ValueKey('selectAll'),
                      minTileHeight: 10,
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          GestureDetector(
                            onTap: toggleSelectAll,
                            child: SizedBox(
                              height: 24,
                              width: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Checkbox(
                                    value: _itemBox.values.every(
                                      (item) => _selectedItemIds.contains(item.key),
                                    ),
                                    onChanged: (bool? value) {
                                      toggleSelectAll();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text('Select All', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    // ReorderableListView for items
                    Expanded(
                      child: ReorderableListView.builder(
                        onReorder: _onReorder,
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          final item = listItems[index];

                          if (currentTab.hasCount &&
                              item.name.endsWith('s') &&
                              !item.name.contains(' ') &&
                              item.count == 1) {
                            item.name = item.name.substring(0, item.name.length - 1);
                            item.save();
                          }

                          return ListTile(
                            key: ValueKey(item.key),
                            minTileHeight: 10,
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 3,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_selectedItemIds.contains(item.key)) {
                                        _selectedItemIds.remove(item.key);
                                      } else {
                                        _selectedItemIds.add(item.key);
                                      }
                                    });
                                  },
                                  child: SizedBox(
                                    height: 24,
                                    width: 50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end, // Align checkbox to the right
                                      children: [
                                        Checkbox(
                                          value: _selectedItemIds.contains(
                                            item.key,
                                          ), // If item is selected
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedItemIds.add(item.key);
                                              } else {
                                                _selectedItemIds.remove(item.key);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Expanded to make the text take the remaining space
                                Expanded(
                                  child: Text(
                                    currentTab.hasCount ? '${item.count} ${item.name}' : item.name,
                                    softWrap:
                                        true, // Ensure text wraps to the next line if it's too long
                                    style: TextStyle(
                                      decoration:
                                          item.completed == true
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                ),
                                // Optional tag display
                                SizedBox(width: 8),
                                if (item.tag != null && item.tag!.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: item.itemTagColor(_tagOrder),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(item.tag!, style: TextStyles.tagText),
                                  ),
                                SizedBox(width: 8),
                                // Date added
                                Text(
                                  dateFormat.format(item.dateAdded),
                                  style: TextStyles.lightText,
                                ),
                              ],
                            ),
                            onTap: () => onItemTapped(item),
                            onLongPress: () => _showEditDialog(item),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (item.url != null && item.url!.isNotEmpty) {
                                      _launchUrl(item.url!);
                                    } else {
                                      showErrorSnackbar(
                                        context,
                                        "No URL set. Update by long pressing item.",
                                      );
                                    }
                                  },
                                  child:
                                      item.url != null && item.url!.isNotEmpty
                                          ? const Icon(Icons.link)
                                          : Icon(Icons.link, color: dullColor),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: const Icon(Icons.drag_indicator), // Drag icon
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
