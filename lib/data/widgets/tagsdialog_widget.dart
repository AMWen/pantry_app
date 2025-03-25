import 'package:flutter/material.dart';

import 'edittagsdialog_widget.dart';
import '../../utils/string_utils.dart';
import '../classes/box_settings.dart';
import '../classes/list_item.dart';
import '../constants.dart';

class TagsDialog extends StatefulWidget {
  final List<ListItem> selectedItems;
  final BoxSettings currentBoxSettings;

  const TagsDialog({super.key, required this.selectedItems, required this.currentBoxSettings});

  @override
  TagsDialogState createState() => TagsDialogState();
}

class TagsDialogState extends State<TagsDialog> {
  late List<String> tagOrder;
  late String selectedTag;

  @override
  void initState() {
    super.initState();
    tagOrder = widget.currentBoxSettings.tags;
    selectedTag = widget.selectedItems[0].tag ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        FilledButton(
          onPressed: () async {
            await showDialog<bool>(
              context: context,
              builder: (context) {
                return EditTagsDialog(currentBoxSettings: widget.currentBoxSettings);
              },
            );
            setState(() {
              tagOrder = widget.currentBoxSettings.tags;
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade700, // Green color for Edit button
          ),
          child: Text('Edit Tags'),
        ),
        FilledButton(
          onPressed: () {
            for (ListItem item in widget.selectedItems) {
              item.tag = selectedTag;
              item.save();
            }
            Navigator.of(context).pop(true); // Close the dialog after selection
          },
          child: Text('Confirm'),
        ),
      ],
      title: Center(child: Text('Select Tag', style: TextStyles.dialogTitle)),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 4.0,
            children:
                tagOrder.map<Widget>((String tag) {
                  bool isSelected = tag == selectedTag;

                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(tag),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : dullColor,
                    ),
                    selected: isSelected,
                    selectedColor: getTagColor(tag, tagOrder),
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
  }
}
