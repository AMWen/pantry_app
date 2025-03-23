import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../data/classes/list_item.dart';
import '../data/constants.dart';
import 'simplelist_screen.dart';

class InventoryListScreen extends SimpleListScreen {
  const InventoryListScreen({
    super.key,
    required super.itemType,
    required super.boxName,
    required super.title,
    super.hasCount = true,
    super.moveTo,
  });

  @override
  InventoryListScreenState createState() => InventoryListScreenState();
}

class InventoryListScreenState extends SimpleListScreenState {
  Box<ListItem>? _itemBox;
  double updateQuantity = 0;

  @override
  void initState() {
    super.initState();
    _itemBox = Hive.box<ListItem>(widget.boxName);
  }

  void _deleteItem(int index) {
    setState(() {
      _itemBox?.deleteAt(index);
    });
  }

  void _updateItem(int index, int newCount) {
    setState(() {
      final item = _itemBox?.getAt(index);
      if (newCount == 0) {
        _deleteItem(index);
      } else if (item != null) {
        item.count = newCount;
        item.save(); // Save the updated item back to the box
      }
    });
  }

  void _showItemDetails(BuildContext context, ListItem item) {
    String displayName =
        item.name.endsWith('s')
            ? item.name.substring(0, item.name.length - 1) // Remove trailing 's'
            : item.name;
    showDialog(
      context: context,
      builder: (context) {
        updateQuantity = item.count?.toDouble() ?? 0.0;

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
                          max: max(item.count?.toDouble() ?? 0.0, updateQuantity),
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
                            final index = _itemBox?.values.toList().indexOf(item);
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
                            final index = _itemBox?.values.toList().indexOf(item);
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  void onItemTapped(BuildContext context, ListItem item) {
    _showItemDetails(context, item);
  }
}