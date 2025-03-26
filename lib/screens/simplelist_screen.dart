import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/classes/box_settings.dart';
import '../data/classes/list_item.dart';
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
import '../utils/snackbar_util.dart';

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

  // late AutoLoadService _autoLoadService;
  // late AutoLoadService _newAutoLoadService;
  late Box<ListItem> _itemBox;
  late Box<ListItem> _newItemBox;
  late List<String> _tagOrder;
  Set<int> _selectedItemIds = {};
  late BoxSettings currentBoxSettings;
  List<ListItem> listItems = [];
  List<ListItem> completedItems = [];
  String? adjustedMoveTo;

  @override
  void initState() {
    super.initState();

    // Set comletion settings
    Box<BoxSettings> boxSettingsBox = getBoxSettingsBox();
    currentBoxSettings = boxSettingsBox.get(widget.boxName)!;

    // _autoLoadService = AutoLoadService();
    // Future.delayed(Duration.zero, () {
    //   if (mounted) {
    //     _autoLoadService.startAutoLoad(
    //       widget.boxName,
    //       showErrorSnackbar: (message) => showErrorSnackbar(context, message),
    //     );
    //   }
    // });
    _itemBox = Hive.box<ListItem>(widget.boxName);
    if (widget.moveTo != null) {
      if (Hive.isBoxOpen(widget.moveTo!)) {
        adjustedMoveTo = widget.moveTo;
        _newItemBox = Hive.box<ListItem>(widget.moveTo!);
        // _newAutoLoadService = AutoLoadService();
        // Future.delayed(Duration.zero, () {
        //   if (mounted) {
        //     _newAutoLoadService.startAutoLoad(
        //       widget.moveTo!,
        //       showErrorSnackbar: (message) => showErrorSnackbar(context, message),
        //     );
        //   }
        // });
      } // moveTo not valid if associated Hive box does not exist / is not open
    }

    _tagOrder = currentBoxSettings.tags;
  }

  @override
  void dispose() {
    // _autoLoadService.stopAutoLoad();
    super.dispose();
  }

  void copySelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      final selectedItems =
          _itemBox.values
              .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
              .toList();

      final itemNames = selectedItems
          .map((item) => widget.hasCount ? '${item.count} ${item.name}' : item.name)
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
    String? message = await autoSave(boxName);
    if (message != null) {
      if (mounted) {
        showErrorSnackbar(context, message);
      }
    }
  }

  void _moveItem(ListItem item) {
    setState(() {
      item.dateAdded = DateTime.now();
      item.save();
      _deleteItem(_itemBox.values.toList().indexOf(item));
      _newItemBox.add(item);
    });
  }

  void _moveSelectedItems() {
    if (_selectedItemIds.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: alertPadding,
            title: AlertTitle(
              'Are you sure you want to move all selected items to $adjustedMoveTo?',
            ),
            content: Text('This action cannot be undone.'),
            actions: [
              CancelButton(),
              FilledButton(
                onPressed: () {
                  final selectedItems =
                      _itemBox.values
                          .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
                          .toList();

                  for (var item in selectedItems) {
                    _moveItem(item);
                  }
                  _selectedItemIds.clear();
                  _setLastUpdatedAndSave(widget.boxName);
                  _setLastUpdatedAndSave(adjustedMoveTo!);

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showErrorSnackbar(context, 'No items selected for migration!');
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _itemBox.deleteAt(index);
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
              FilledButton(
                onPressed: () {
                  final selectedItems =
                      _itemBox.values
                          .where((item) => _selectedItemIds.contains(item.key)) // Use key to filter
                          .toList();

                  for (var item in selectedItems) {
                    _deleteItem(_itemBox.values.toList().indexOf(item));
                  }
                  _selectedItemIds.clear();
                  _setLastUpdatedAndSave(widget.boxName);

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
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

  void onItemTapped(ListItem item) {
    item.completed = (item.completed ?? false) ? false : true;
    item.save();
    _setLastUpdatedAndSave(widget.boxName);
  }

  void _showEditDialog(ListItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(item: item, boxName: widget.boxName, hasCount: widget.hasCount);
      },
    );
  }

  void _showSaveLoadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SaveLoadDialog(
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

    for (int i = 0; i < listItems.length; i++) {
      // Create a new instance of ListItem to avoid same instance error
      // Note: putAt index different from key, but key in index gets reused, effectively replacing old object
      final newItem = ListItem.fromJson(listItems[i].toJson());
      _itemBox.putAt(i, newItem);
    }

    setState(() {
      currentBoxSettings.sortCriteria = '';
      currentBoxSettings.save();
    });
    _setLastUpdatedAndSave(widget.boxName);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> actionList = [
      if (adjustedMoveTo != null) {'icon': Icons.local_shipping, 'onPressed': _moveSelectedItems},
      if (!widget.hasCount) // Only add this action if hasCount is false
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
          PopupMenu(),
          Padding(padding: const EdgeInsets.only(right: 4)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
        child: ValueListenableBuilder(
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
                  title: Row(
                    children: [
                      SizedBox(
                        height: 24, // Used to remove padding from Checkbox
                        child: Checkbox(
                          value: _itemBox.values.every(
                            (item) => _selectedItemIds.contains(item.key),
                          ), // Check if all items are selected
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedItemIds = _itemBox.values.fold<Set<int>>({}, (
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
                                  color: item.itemTagColor(_tagOrder),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(item.tag!, style: TextStyles.tagText),
                              ),
                            SizedBox(width: 8),
                            Text(dateFormat.format(item.dateAdded), style: TextStyles.lightText),
                          ],
                        ),
                        onTap: () => onItemTapped(item),
                        onLongPress: () => _showEditDialog(item),
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
    );
  }
}
