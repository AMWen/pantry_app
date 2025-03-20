import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List
import '../data/classes/pantry_item.dart';
import 'additem_screen.dart';
import '../data/constants.dart';
import '../utils/string_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Box<PantryItem>? _pantryBox;
  double updateQuantity = 0;
  String _sortCriteria = 'name'; // Default sorting by name
  Set<int> _selectedItemIds = {}; // Track selected item IDs

  @override
  void initState() {
    super.initState();
    _pantryBox = Hive.box<PantryItem>('pantry');
  }

  void _addItem(PantryItem item) {
    setState(() {
      _pantryBox?.add(item);
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _pantryBox?.deleteAt(index);
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
                      _pantryBox!.values
                          .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
                          .toList();

                  for (var item in selectedItems) {
                    _deleteItem(_pantryBox!.values.toList().indexOf(item));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 700),
          content: Text('No items selected for deletion!'),
        ),
      );
    }
  }

  void _showTaggingOptions(BuildContext context) {
    if (_selectedItemIds.isNotEmpty) {
      final selectedItems =
          _pantryBox!.values
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
                      for (PantryItem item in selectedItems) {
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
                          tagOrder.map<Widget>((String tag) {
                            bool isSelected = tag == selectedTag;

                            return ChoiceChip(
                              label: Text(tag),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              selected: isSelected,
                              selectedColor: getTagColor(tag),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 700),
          content: Text('No items selected for tagging!'),
        ),
      );
    }
  }

  void _updateItem(int index, int newCount) {
    setState(() {
      final item = _pantryBox?.getAt(index);
      if (newCount == 0) {
        _deleteItem(index);
      } else if (item != null) {
        item.count = newCount;
        item.save(); // Save the updated item back to the box
      }
    });
  }

  // Method to handle sorting options
  void _sortPantryItems(String criteria) {
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
      // Read the file and parse JSON
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      // Add each item to the pantry box
      for (var itemData in jsonList) {
        final pantryItem = PantryItem.fromJson(itemData);
        if (mounted) {
          setState(() {
            _pantryBox?.add(pantryItem);
          });
        }
      }

      // Only show the snackbar if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Items imported successfully!')));
      }
    }
  }

  Future<void> _exportItems() async {
    final pantryItems = _pantryBox?.values.toList() ?? [];

    if (pantryItems.isNotEmpty) {
      final jsonList = pantryItems.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final params = SaveFileDialogParams(
        fileName: 'pantry_items.json',
        mimeTypesFilter: ['application/json'],
        data: Uint8List.fromList(jsonString.codeUnits),
      );

      final filePath = await FlutterFileDialog.saveFile(params: params);
      if (filePath != null) {
        final file = File(filePath);
        await file.writeAsString(jsonString);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Items exported successfully!')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No items to export!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantry'),
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
              // Show a bottom sheet or alert to choose between import or export
              _showImportExportOptions();
            },
          ),
          IconButton(
            icon: Icon(Icons.label),
            onPressed: () {
              // Show a bottom sheet or alert to choose between import or export
              _showTaggingOptions(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _deleteSelectedItems, // Handle the deletion of selected items
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 20, top: 20, bottom: 20),
        child: ValueListenableBuilder(
          valueListenable: _pantryBox!.listenable(),
          builder: (context, Box<PantryItem> box, _) {
            if (box.values.isEmpty) {
              return Center(child: Text('No items in pantry.'));
            }

            // Original pantry list
            var pantryItems = box.values.toList();

            // Sort the pantry items based on selected criteria
            if (_sortCriteria == 'name') {
              pantryItems.sort((a, b) => a.name.compareTo(b.name));
            } else if (_sortCriteria == 'dateAdded') {
              pantryItems.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
            } else if (_sortCriteria == 'tag') {
              pantryItems.sort((a, b) {
                int aIndex = tagOrder.indexOf(a.tag ?? 'other');
                int bIndex = tagOrder.indexOf(b.tag ?? 'other');
                return aIndex.compareTo(bIndex);
              });
            }

            return ListView.builder(
              itemCount: pantryItems.length + 1, // Add 1 for the "Select All" checkbox
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Select All Checkbox
                  return ListTile(
                    minTileHeight: 10,
                    title: Text('Select All', style: TextStyle(fontWeight: FontWeight.w600)),
                    leading: Checkbox(
                      value: pantryItems.every(
                        (item) => _selectedItemIds.contains(item.key),
                      ), // Check if all items are selected
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            // Select all
                            _selectedItemIds = pantryItems.fold<Set<int>>({}, (
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
                  );
                } else {
                  final item = pantryItems[index - 1]; // Subtract 1 to match pantry item index

                  return ListTile(
                    minTileHeight: 10,
                    leading: Checkbox(
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.count} ${item.name}'),
                        if (item.tag != null && item.tag!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: item.itemTagColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(item.tag!, style: TextStyles.tagText),
                          ),
                        Text(
                          DateFormat('M/d/yy').format(item.dateAdded), // Format the date
                          style: TextStyle(
                            color: Colors.grey, // Lighter font color
                            fontWeight: FontWeight.w300, // Lighter weight
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showItemDetails(context, item),
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
            MaterialPageRoute(builder: (context) => AddItemScreen(onItemAdded: _addItem)),
          );
        },
        foregroundColor: Colors.grey[100],
        child: Icon(Icons.add),
      ),
    );
  }

  void _showItemDetails(BuildContext context, PantryItem item) {
    String displayName =
        item.name.endsWith('s')
            ? item.name.substring(0, item.name.length - 1) // Remove trailing 's'
            : item.name;
    showDialog(
      context: context,
      builder: (context) {
        updateQuantity = item.count.toDouble();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
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
              content: Column(
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
                          padding: EdgeInsets.zero,
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
                          final index = _pantryBox?.values.toList().indexOf(item);
                          if (index != null && index >= 0) {
                            _updateItem(
                              index,
                              updateQuantity.toInt(),
                            ); // Update the item count with the selected quantity
                          }
                          updateQuantity = 0;
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Update Quantity'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: primaryColor),
                        onPressed: () {
                          final index = _pantryBox?.values.toList().indexOf(item);
                          if (index != null && index >= 0) {
                            _deleteItem(index);
                          }
                          updateQuantity = 0;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Function to show sorting options in a dialog
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
                  _sortPantryItems('name');
                },
              ),
              ListTile(
                title: Text('Date Added'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sortPantryItems('dateAdded');
                },
              ),
              ListTile(
                title: Text('Tag'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sortPantryItems('tag');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
