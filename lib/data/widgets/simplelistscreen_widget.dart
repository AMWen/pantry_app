import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List
import '../classes/list_item.dart';
import '../constants.dart';
import '../../screens/additem_screen.dart';
import '../../utils/string_utils.dart';

class SimpleListScreen extends StatefulWidget {
  final String itemType;
  final String boxName; // Can be different (e.g. shopping box for pantry items)
  final String title;
  final bool hasCount;

  const SimpleListScreen({
    super.key,
    required this.itemType,
    required this.boxName,
    required this.title,
    this.hasCount = false
  });

  @override
  SimpleListScreenState createState() => SimpleListScreenState();
}

class SimpleListScreenState extends State<SimpleListScreen> {
  Box<ListItem>? _itemBox;
  List<String>? _tagOrder;
  String _sortCriteria = 'dateAdded';
  Set<int> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _itemBox = Hive.box<ListItem>(widget.boxName);
    if (itemTypeTagMapping.containsKey(widget.itemType)) {
      _tagOrder = itemTypeTagMapping[widget.itemType];
    } else {
      _tagOrder = [''];
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: Duration(milliseconds: 700)));
  }

  void _addItem(ListItem item) {
    setState(() {
      _itemBox?.add(item);
    });
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
            title: Text('Are you sure you want to delete all selected items?'),
            content: Text('This action cannot be undone.'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // More prominent color for the "Cancel" button
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
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
      _showErrorSnackbar('No items selected for deletion!');
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
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
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
      _showErrorSnackbar('No items selected for tagging!');
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
          title: Text('Save or Load'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Load Items'),
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
        _showErrorSnackbar('Items imported successfully!');
      }
    }
  }

  Future<void> _exportItems() async {
    final listItems = _itemBox?.values.toList() ?? [];

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
          _showErrorSnackbar('Items exported successfully!');
        }
      }
    } else {
      if (mounted) {
        _showErrorSnackbar('No items to export!');
      }
    }
  }

  void _showSortingOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Name'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sortListItems('name');
                },
              ),
              ListTile(
                title: Text('Date Added'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sortListItems('dateAdded');
                },
              ),
              ListTile(
                title: Text('Tag'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sortListItems('tag');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void onItemTapped(BuildContext context, ListItem item) {
    item.completed = (item.completed ?? false) ? false : true;
    item.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_vert),
            onPressed: () {
              // Show sorting options using AlertDialog
              _showSortingOptions(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _showImportExportOptions();
            },
          ),
          IconButton(
            icon: Icon(Icons.label),
            onPressed: () {
              _showTaggingOptions(context);
            },
          ),
          IconButton(icon: Icon(Icons.delete_forever), onPressed: _deleteSelectedItems),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 20, top: 20, bottom: 20),
        child: ValueListenableBuilder(
          valueListenable: _itemBox!.listenable(),
          builder: (context, Box<ListItem> box, _) {
            if (box.values.isEmpty) {
              return Center(child: Text('No items added yet.'));
            }

            var listItems = box.values.toList(); // Original list

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

            return ListView.builder(
              itemCount: listItems.length + 1, // Add 1 for the "Select All" checkbox
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Select All Checkbox
                  return ListTile(
                    minTileHeight: 10,
                    title: Row(
                      children: [
                        SizedBox(
                          height: 24, // Used to remove padding from Checkbox
                          child: Checkbox(
                            value: listItems.every(
                              (item) => _selectedItemIds.contains(item.key),
                            ), // Check if all items are selected
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  // Select all
                                  _selectedItemIds = listItems.fold<Set<int>>({}, (
                                    Set<int> selectedIds,
                                    item,
                                  ) {
                                    selectedIds.add(item.key);
                                    return selectedIds;
                                  });
                                } else {
                                  // Deselect all
                                  _selectedItemIds.clear();
                                }
                              });
                            },
                          ),
                        ),
                        Text('Select All', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                } else {
                  final item = listItems[index - 1]; // Subtract 1 to match item index

                  return ListTile(
                    minTileHeight: 10,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24, // Used to remove padding from Checkbox
                          child: Checkbox(
                            value: _selectedItemIds.contains(
                              item.key,
                            ), // Use item key for selection state
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
                            softWrap: true, // Ensure text wraps to the next line if it's too long
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
                        Text(
                          DateFormat('M/d/yy').format(item.dateAdded), // Format the date
                          style: TextStyles.lightText,
                        ),
                      ],
                    ),
                    onTap: () => onItemTapped(context, item),
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(onItemAdded: _addItem, itemType: widget.itemType, hasCount: widget.hasCount),
            ),
          );
        },
        foregroundColor: Colors.grey[100],
        child: Icon(Icons.add),
      ),
    );
  }
}
