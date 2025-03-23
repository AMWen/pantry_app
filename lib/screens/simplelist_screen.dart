import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List
import '../data/classes/list_item.dart';
import '../data/constants.dart';
import '../data/widgets/basic_widgets.dart';
import '../data/widgets/editdialog_widget.dart';
import '../data/widgets/settingsdialog_widget.dart';
import '../utils/string_utils.dart';
import 'additem_screen.dart';

class SimpleListScreen extends StatefulWidget {
  final String itemType;
  final String boxName; // Can be different (e.g. shopping box for pantry items)
  final String title;
  final bool hasCount;
  final String? moveTo;

  const SimpleListScreen({
    super.key,
    required this.itemType,
    required this.boxName,
    required this.title,
    this.hasCount = false,
    this.moveTo,
  });

  @override
  SimpleListScreenState createState() => SimpleListScreenState();
}

class SimpleListScreenState extends State<SimpleListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Box<ListItem>? _itemBox;
  Box<ListItem>? _newItemBox;
  List<String>? _tagOrder;
  String _sortCriteria = '';
  Set<int> _selectedItemIds = {};
  bool _showCompleted = true;
  bool _selectAllCompleted = false;
  List<ListItem> listItems = [];
  List<ListItem> completedItems = [];

  @override
  void initState() {
    super.initState();
    _itemBox = Hive.box<ListItem>(widget.boxName);
    if (widget.moveTo != null) {
      _newItemBox = Hive.box<ListItem>(widget.moveTo!);
    }
    if (itemTypeTagMapping.containsKey(widget.itemType)) {
      _tagOrder = itemTypeTagMapping[widget.itemType];
    } else {
      _tagOrder = [''];
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: Duration(milliseconds: 700)));
  }

  void _addItem(ListItem item) {
    setState(() {
      _itemBox?.add(item);
    });
  }

  void _moveItem(ListItem item) {
    setState(() {
      _deleteItem(_itemBox!.values.toList().indexOf(item));
      _newItemBox?.add(item);
    });
  }

  void _moveSelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: AlertTitle(
              'Are you sure you want to move all selected items to ${widget.moveTo}?',
            ),
            content: Text('This action cannot be undone.'),
            actions: [
              CancelButton(),
              ElevatedButton(
                onPressed: () {
                  final selectedItems =
                      _itemBox!.values
                          .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
                          .toList();

                  for (var item in selectedItems) {
                    _moveItem(item);
                  }
                  _selectedItemIds.clear();

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showErrorSnackbar('No items selected for migration!');
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _itemBox?.deleteAt(index);
    });
  }

  void _deleteSelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: AlertTitle('Are you sure you want to delete all selected items?'),
            content: Text('This action cannot be undone.'),
            actions: [
              CancelButton(),
              ElevatedButton(
                onPressed: () {
                  final selectedItems =
                      _itemBox!.values
                          .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
                          .toList();

                  for (var item in selectedItems) {
                    _deleteItem(_itemBox!.values.toList().indexOf(item));
                  }
                  _selectedItemIds.clear();

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showErrorSnackbar('No items selected for deletion!');
    }
  }

  void _showTaggingOptions(BuildContext context) {
    if (_selectedItemIds.isNotEmpty) {
      final selectedItems =
          _itemBox!.values
              .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
              .toList();

      showDialog(
        context: context,
        builder: (context) {
          String selectedTag = '';

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                actions: [
                  FilledButton(
                    onPressed: () {
                      for (ListItem item in selectedItems) {
                        item.tag = selectedTag;
                        item.save();
                      }
                      _selectedItemIds.clear();
                      Navigator.of(context).pop(); // Close the dialog after selection
                    },
                    child: Text('Confirm'),
                  ),
                ],
                title: Center(child: Text('Select Tag', style: TextStyles.dialogTitle)),
                content: SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 4.0,
                      children:
                          _tagOrder!.map<Widget>((String tag) {
                            bool isSelected = tag == selectedTag;

                            return ChoiceChip(
                              label: Text(tag),
                              labelStyle: TextStyle(color: isSelected ? Colors.white : dullColor),
                              selected: isSelected,
                              selectedColor: getTagColor(tag, widget.itemType),
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedTag = selected ? tag : '';
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      showErrorSnackbar('No items selected for tagging!');
    }
  }

  void _sortListItems(String criteria) {
    setState(() {
      _sortCriteria = criteria;
    });
  }

  void _showImportExportOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: AlertTitle('Save or Load'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Load Items (add to list)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _importItems();
                },
              ),
              ListTile(
                title: Text('Save Items'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportItems();
                },
              ),
              ListTile(
                title: Text('Save Selected'),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportItems(selectedOnly: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _importItems() async {
    final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      fileExtensionsFilter: ['json'], // Only allow JSON files
    );

    final filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath != null) {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      // Add each item to the item box
      for (var itemData in jsonList) {
        final listItem = ListItem.fromJson(itemData);
        if (mounted) {
          setState(() {
            _itemBox?.add(listItem);
          });
        }
      }

      // Only show the snackbar if the widget is still mounted
      if (mounted) {
        showErrorSnackbar('Items imported successfully!');
      }
    }
  }

  Future<void> _exportItems({bool selectedOnly = false}) async {
    final listItems =
        selectedOnly
            ? _itemBox?.values.where((item) => _selectedItemIds.contains(item.key)).toList() ?? []
            : _itemBox?.values.toList() ?? [];

    if (listItems.isNotEmpty) {
      final jsonList = listItems.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final params = SaveFileDialogParams(
        fileName: '${widget.boxName}_items.json',
        mimeTypesFilter: ['application/json'],
        data: Uint8List.fromList(jsonString.codeUnits),
      );

      final filePath = await FlutterFileDialog.saveFile(params: params);
      if (filePath != null) {
        final file = File(filePath);
        await file.writeAsString(jsonString);
        if (mounted) {
          showErrorSnackbar('Items exported successfully!');
        }
      }
    } else {
      if (mounted) {
        showErrorSnackbar('No items to export!');
      }
    }
  }

  // Future<String?> getFileLocation(String boxName) async {
  //   var settingsBox = Hive.box<Settings>('settings');
  //   var settings = settingsBox.get(boxName);
  //   return settings?.fileLocation;
  // }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsDialog();
      },
    );
  }

  void _showSortingOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: AlertTitle('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                sortOptions.map((option) {
                  return ListTile(
                    title: Text(option['title']!),
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

  void onItemTapped(BuildContext context, ListItem item) {
    item.completed = (item.completed ?? false) ? false : true;
    item.save();
  }

  void _showEditDialog(BuildContext context, ListItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(item: item, hasCount: widget.hasCount);
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
    if (!_showCompleted) {
      listItems = [...listItems, ...completedItems];
    }

    // _itemBox!.clear();
    for (int i = 0; i < listItems.length; i++) {
      // Create a new instance of ListItem to avoid same instance error
      final newItem = ListItem(
        name: listItems[i].name,
        dateAdded: listItems[i].dateAdded,
        count: listItems[i].count,
        tag: listItems[i].tag,
        completed: listItems[i].completed,
        itemType: listItems[i].itemType,
      );
      _itemBox!.putAt(i, newItem);
    }

    setState(() {
      _sortCriteria = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> actionList = [
      if (widget.moveTo != null) {'icon': Icons.local_shipping, 'onPressed': _moveSelectedItems},
      if (!widget.hasCount) // Only add this action if hasCount is false
        {
          'icon':
              _selectAllCompleted
                  ? Icons.visibility_off
                  : _showCompleted
                  ? Icons.check_box
                  : Icons.visibility,
          'onPressed': () {
            setState(() {
              if (_selectAllCompleted) {
                _showCompleted = false;
                _selectAllCompleted = false;
                _selectedItemIds.clear();
              } else if (_showCompleted) {
                _showCompleted = true;
                _selectAllCompleted = true;
                _selectedItemIds = _itemBox!.values.fold<Set<int>>({}, (
                  Set<int> selectedIds,
                  item,
                ) {
                  if (item.completed == true) {
                    selectedIds.add(item.key);
                  }
                  return selectedIds;
                });
              } else {
                _showCompleted = true;
                _selectAllCompleted = false;
                _selectedItemIds.clear();
              }
            });
          },
        },
      {
        'icon': Icons.swap_vert,
        'onPressed': () {
          _showSortingOptions(context);
        },
      },
      {
        'icon': Icons.save,
        'onPressed': () {
          _showImportExportOptions();
        },
      },
      {
        'icon': Icons.label,
        'onPressed': () {
          _showTaggingOptions(context);
        },
      },
      {'icon': Icons.delete_forever, 'onPressed': _deleteSelectedItems},
      {
        'icon': Icons.settings,
        'onPressed': () {
          _showSettings();
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...actionList.map(
            (action) => SizedBox(
              width: 40,
              child: IconButton(icon: Icon(action['icon']), onPressed: action['onPressed']),
            ),
          ),
          Padding(padding: const EdgeInsets.only(right: 5)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
        child: ValueListenableBuilder(
          valueListenable: _itemBox!.listenable(),
          builder: (context, Box<ListItem> box, _) {
            if (box.values.isEmpty) {
              return Center(child: Text('No items added yet.'));
            }

            listItems = box.values.toList(); // Original list
            completedItems = listItems.where((item) => item.completed == true).toList();

            // Filter out completed items
            if (!_showCompleted) {
              listItems =
                  listItems
                      .where((item) => item.completed == false || item.completed == null)
                      .toList();
            }

            // Sort the items based on selected criteria
            if (_sortCriteria == 'name') {
              listItems.sort((a, b) => a.name.compareTo(b.name));
            } else if (_sortCriteria == 'dateAdded') {
              listItems.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
            } else if (_sortCriteria == 'tag') {
              listItems.sort((a, b) {
                int aIndex = _tagOrder!.indexOf(a.tag ?? 'other');
                int bIndex = _tagOrder!.indexOf(b.tag ?? 'other');
                return aIndex.compareTo(bIndex);
              });
            }

            return Column(
              children: [
                // "Select All" checkbox row
                ListTile(
                  key: ValueKey('selectAll'),
                  minTileHeight: 10,
                  title: Row(
                    children: [
                      SizedBox(
                        height: 24, // Used to remove padding from Checkbox
                        child: Checkbox(
                          value: _itemBox!.values.every(
                            (item) => _selectedItemIds.contains(item.key),
                          ), // Check if all items are selected
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedItemIds = _itemBox!.values.fold<Set<int>>({}, (
                                  Set<int> selectedIds,
                                  item,
                                ) {
                                  selectedIds.add(item.key);
                                  return selectedIds;
                                });
                              } else {
                                _selectedItemIds.clear();
                              }
                            });
                          },
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

                      if (widget.hasCount && item.name.endsWith('s') && item.count == 1) {
                        item.name = item.name.substring(0, item.name.length - 1);
                        item.save();
                      }

                      return ListTile(
                        key: ValueKey(item.key),
                        minTileHeight: 10,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24, // Used to remove padding from Checkbox
                              child: Checkbox(
                                value: _selectedItemIds.contains(item.key),
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
                            ),
                            Expanded(
                              child: Text(
                                widget.hasCount ? '${item.count} ${item.name}' : item.name,
                                softWrap:
                                    true, // Ensure text wraps to the next line if it's too long
                                style: TextStyle(
                                  decoration:
                                      item.completed == true ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (item.tag != null && item.tag!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: item.itemTagColor(),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(item.tag!, style: TextStyles.tagText),
                              ),
                            SizedBox(width: 8),
                            Text(dateFormat.format(item.dateAdded), style: TextStyles.lightText),
                          ],
                        ),
                        onTap: () => onItemTapped(context, item),
                        onLongPress: () => _showEditDialog(context, item),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_indicator),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: //Transform.translate(
      // offset: Offset(0, 28),
      //child:
      FloatingActionButton(
        heroTag: 'screen_fab',
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddItemScreen(
                    onItemAdded: _addItem,
                    itemType: widget.itemType,
                    hasCount: widget.hasCount,
                  ),
            ),
          );
        },
        foregroundColor: Colors.grey[100],
        child: Icon(Icons.add),
      ),
      // ),
    );
  }
}
