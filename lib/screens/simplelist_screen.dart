import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/classes/completion_settings.dart';
import '../data/classes/list_item.dart';
import '../data/constants.dart';
// import '../data/widgets/autoloadservice_widget.dart';
import '../data/widgets/basic_widgets.dart';
import '../data/widgets/editdialog_widget.dart';
// import '../data/widgets/syncdialog_widget.dart';
import '../data/widgets/snackbar_widget.dart';
import '../utils/file_utils.dart';
import '../utils/string_utils.dart';

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
  String _sortCriteria = '';
  Set<int> _selectedItemIds = {};
  late CompletionSettings boxCompletionSettings;
  List<ListItem> listItems = [];
  List<ListItem> completedItems = [];

  @override
  void initState() {
    super.initState();

    // Set comletion settings
    Box<CompletionSettings> completionSettingsBox = Hive.box<CompletionSettings>(completionSettings);
    boxCompletionSettings = completionSettingsBox.get(widget.boxName)!;

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
    }
    if (itemTypeTagMapping.containsKey(widget.itemType)) {
      _tagOrder = itemTypeTagMapping[widget.itemType]!;
    } else {
      _tagOrder = [''];
    }
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
            title: AlertTitle(
              'Are you sure you want to move all selected items to ${widget.moveTo}?',
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
                  _setLastUpdatedAndSave(widget.moveTo!);

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

  void _showTaggingOptions(BuildContext context) {
    if (_selectedItemIds.isNotEmpty) {
      final selectedItems =
          _itemBox.values
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
                      _setLastUpdatedAndSave(widget.boxName);
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
                          _tagOrder.map<Widget>((String tag) {
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
      showErrorSnackbar(context, 'No items selected for tagging!');
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
    final filePath = await pickLocation();
    String message = await importItemsFromFile(filePath, widget.boxName);

    if (mounted) {
      showErrorSnackbar(context, message);
    }
    _setLastUpdatedAndSave(widget.boxName);
  }

  Future<void> _exportItems({bool selectedOnly = false}) async {
    final listItems =
        selectedOnly
            ? _itemBox.values.where((item) => _selectedItemIds.contains(item.key)).toList()
            : _itemBox.values.toList();

    if (listItems.isEmpty) {
      if (mounted) {
        showErrorSnackbar(context, 'No items to export!');
      }
    } else {
      String message = await exportItemsWithSaveDialog('${widget.boxName}_items.json', listItems);

      if (mounted) {
        showErrorSnackbar(context, message);
      }
    }
  }

  // void _showSync() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SyncDialog();
  //     },
  //   );
  // }

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
    _setLastUpdatedAndSave(widget.boxName);
  }

  void _showEditDialog(BuildContext context, ListItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(item: item, boxName: widget.boxName, hasCount: widget.hasCount);
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
    if (!boxCompletionSettings.showCompleted) {
      listItems = [...listItems, ...completedItems];
    }

    for (int i = 0; i < listItems.length; i++) {
      // Create a new instance of ListItem to avoid same instance error
      // Note: putAt index different from key, but key in index gets reused, effectively replacing old object
      final newItem = ListItem.fromJson(listItems[i].toJson());
      _itemBox.putAt(i, newItem);
    }

    setState(() {
      _sortCriteria = '';
    });
    _setLastUpdatedAndSave(widget.boxName);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> actionList = [
      if (widget.moveTo != null) {'icon': Icons.local_shipping, 'onPressed': _moveSelectedItems},
      if (!widget.hasCount) // Only add this action if hasCount is false
        {
          'icon':
              boxCompletionSettings.selectAllCompleted
                  ? Icons.visibility_off
                  : boxCompletionSettings.showCompleted
                  ? Icons.check_box
                  : Icons.visibility,
          'onPressed': () {
            setState(() {
              if (boxCompletionSettings.selectAllCompleted) {
                boxCompletionSettings.showCompleted = false;
                boxCompletionSettings.selectAllCompleted = false;
                _selectedItemIds.clear();
              } else if (boxCompletionSettings.showCompleted) {
                boxCompletionSettings.showCompleted = true;
                boxCompletionSettings.selectAllCompleted = true;
                _selectedItemIds = _itemBox.values.fold<Set<int>>({}, (Set<int> selectedIds, item) {
                  if (item.completed == true) {
                    selectedIds.add(item.key);
                  }
                  return selectedIds;
                });
              } else {
                boxCompletionSettings.showCompleted = true;
                boxCompletionSettings.selectAllCompleted = false;
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
        'icon': Icons.info,
        'onPressed': () {
          _launchUrl(
            'https://github.com/AMWen/pantry_app?tab=readme-ov-file#key-features-in-detail',
          );
        },
      },
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
              width: 36,
              child: IconButton(icon: Icon(action['icon']), onPressed: action['onPressed']),
            ),
          ),
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
            if (!boxCompletionSettings.showCompleted) {
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
    );
  }
}
