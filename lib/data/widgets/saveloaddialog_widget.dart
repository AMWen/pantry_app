import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../utils/file_utils.dart';
import '../classes/list_item.dart';
import '../constants.dart';
import 'basic_widgets.dart';
import 'snackbar_widget.dart';

class SaveLoadDialog extends StatefulWidget {
  final String boxName;
  final Box<ListItem> itemBox;
  final Set<int> selectedItemIds;

  const SaveLoadDialog({
    super.key,
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

  List<Widget> generateListTiles(BuildContext context, List<Map<String, dynamic>> actions) {
    return actions.map((action) {
      return ListTile(
        minTileHeight: 10,
        title: Text(action['title'], style: TextStyles.mediumText),
        onTap: () {
          Navigator.of(context).pop();
          action['action']();
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AlertTitle('Save or Load'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: generateListTiles(context, [
          {'title': 'Load Items (add to list)', 'action': () => _loadItems(add: true)},
          {'title': 'Load Items (replace list)', 'action': () => _loadItems(add: false)},
          {'title': 'Save Items', 'action': () => _saveItems()},
          {'title': 'Save Selected', 'action': () => _saveItems(selectedOnly: true)},
        ]),
      ),
    );
  }
}
