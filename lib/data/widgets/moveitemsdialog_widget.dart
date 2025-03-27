import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'basic_widgets.dart';
import '../classes/list_item.dart';
import '../classes/tab_configuration.dart';
import '../constants.dart';
import '../../utils/hivebox_utils.dart';
import '../../utils/widget_utils.dart';

class MoveItemsDialog extends StatefulWidget {
  final String boxName;
  final Box<ListItem> itemBox;
  final Set<int> selectedItemIds;

  const MoveItemsDialog({
    super.key,
    required this.boxName,
    required this.itemBox,
    required this.selectedItemIds,
  });

  @override
  MoveItemsDialogState createState() => MoveItemsDialogState();
}

class MoveItemsDialogState extends State<MoveItemsDialog> {
  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  late TabConfiguration currentTab;
  late List<String> moveToOptions;
  ValueNotifier<String> moveToDropdownNotifier = ValueNotifier<String>('');
  late String? moveTo;
  late Map<String, String> boxNameToTitleMap;
  @override
  void initState() {
    super.initState();
    currentTab = tabBox.get(widget.boxName)!;
    boxNameToTitleMap = {for (var config in tabBox.values) config.key: config.title};
    moveToOptions = boxNameToTitleMap.keys.toList();
    if (moveToOptions.contains(currentTab.moveTo)) {
      moveTo = currentTab.moveTo;
    } else {
      moveTo = widget.boxName;
    }
    moveToDropdownNotifier.value = moveTo!;
  }

  void _moveItem(ListItem item) {
    setState(() {
      item.dateAdded = DateTime.now();
      item.save();
      widget.itemBox.delete(item.key);

      Box<ListItem> newItemBox = Hive.box<ListItem>(moveTo!);
      newItemBox.add(item);
    });
  }

  void _moveSelectedItems() {
    if (moveTo != null && moveToOptions.contains(moveTo)) {
      final selectedItems =
          widget.itemBox.values.where((item) => widget.selectedItemIds.contains(item.key)).toList();
      for (var item in selectedItems) {
        _moveItem(item);
      }
      Navigator.of(context).pop(moveTo);
    } else {
      showErrorSnackbar(context, 'Not a valid list to move to!');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: alertPadding,
      title: AlertTitle('Are you sure you want to move all selected items?'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This action cannot be undone.'),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text('Move to:', style: TextStyles.boldText),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: moveToDropdownNotifier,
                      builder: (context, newMoveTo, child) {
                        return DropdownButton<String>(
                          underline: Container(),
                          style: TextStyles.normalText,
                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          isDense: true,
                          value: newMoveTo,
                          onChanged: (String? newValue) {
                            moveTo = newValue ?? widget.boxName;
                            moveToDropdownNotifier.value = moveTo!;
                          },
                          items:
                              moveToOptions.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(boxNameToTitleMap[value] ?? '(Unknown)'),
                                );
                              }).toList(),
                        );
                      },
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
          onPressed: () {
            _moveSelectedItems();
          },
        ),
      ],
    );
  }
}
