import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../utils/file_utils.dart';
import '../classes/list_item.dart';
import '../constants.dart';
import 'basic_widgets.dart';
import '../../utils/widget_utils.dart';

class SaveLoadDialog extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final String boxName;
  final Box<ListItem> itemBox;
  final Set<int> selectedItemIds;

  const SaveLoadDialog({
    super.key,
    required this.refreshNotifier,
    required this.boxName,
    required this.itemBox,
    required this.selectedItemIds,
  });

  @override
  SaveLoadDialogState createState() => SaveLoadDialogState();
}

class SaveLoadDialogState extends State<SaveLoadDialog> {
  Future<void> _loadItems({bool add = true}) async {
    final filePath = await pickLocation();
    String message = await loadItemsFromFile(filePath, widget.boxName, add: add);

    if (mounted) {
      showErrorSnackbar(context, message);
    }
  }

  Future<void> _saveItems({bool selectedOnly = false}) async {
    final listItems =
        selectedOnly
            ? widget.itemBox.values
                .where((item) => widget.selectedItemIds.contains(item.key))
                .toList()
            : widget.itemBox.values.toList();

    if (listItems.isEmpty) {
      if (mounted) {
        showErrorSnackbar(context, 'No items to save!');
      }
    } else {
      String message = await saveItemsWithSaveDialog('${widget.boxName}_items.json', listItems);

      if (mounted) {
        showErrorSnackbar(context, message);
      }
    }
  }

  Future<void> _importAll() async {
    final filePath = await pickLocation();
    String message = await loadAllFromFile(filePath);
    widget.refreshNotifier.value++;

    if (mounted) {
      showErrorSnackbar(context, message);
    }
  }

  Future<void> _exportAll() async {
    String message = await saveAllToFile('export_all_items.json');

    if (mounted) {
      showErrorSnackbar(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: alertPadding,
      title: AlertTitle('Save or Load'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: generateListTiles(context, [
          {'title': 'Load Items (add to list)', 'action': () => _loadItems(add: true)},
          {'title': 'Load Items (replace list)', 'action': () => _loadItems(add: false)},
          {'title': 'Save Items', 'action': () => _saveItems()},
          {'title': 'Save Selected', 'action': () => _saveItems(selectedOnly: true)},
          {'title': 'Import All (overwrites!)', 'action': () => _importAll()},
          {'title': 'Export All', 'action': () => _exportAll()},
        ]),
      ),
      actions: [CancelButton()],
    );
  }
}
