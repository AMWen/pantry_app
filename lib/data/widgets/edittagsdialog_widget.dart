import 'package:flutter/material.dart';

import '../../data/widgets/basic_widgets.dart';
import '../classes/box_settings.dart';
import '../constants.dart';

class EditTagsDialog extends StatefulWidget {
  final BoxSettings currentBoxSettings;

  const EditTagsDialog({super.key, required this.currentBoxSettings});

  @override
  EditTagsDialogState createState() => EditTagsDialogState();
}

class EditTagsDialogState extends State<EditTagsDialog> {
  late List<String> tagOrder;
  String selectedTag = '';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    tagOrder = widget.currentBoxSettings.tags;
    _controller = TextEditingController(text: tagOrder.join('\n').trimRight());
  }

  void _saveEditedTags() {
    final inputText = _controller.text.trim();
    final lines = inputText.split('\n').map((line) => line.trim()).toList();
    final updatedTags = List<String>.from(lines.where((line) => line.isNotEmpty).toSet());
    updatedTags.add('');

    setState(() {
      tagOrder = updatedTags;
    });

    widget.currentBoxSettings.tags = updatedTags;
    widget.currentBoxSettings.save();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: alertPadding,
      title: Text('Edit Tags', style: TextStyles.dialogTitle),
      content: TextField(
        style: TextStyles.normalText,
        controller: _controller,
        maxLines: null, // Allow multiple lines
        decoration: InputDecoration(
          hintText: 'Enter tags, each on a new line',
          hintStyle: TextStyles.hintText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        keyboardType: TextInputType.multiline,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CancelButton(
                text: 'Default',
                onPressed: () {
                  widget.currentBoxSettings.resetTags();
                  setState(() {
                    tagOrder = widget.currentBoxSettings.tags;
                    _controller.text = tagOrder.join('\n').trimRight();
                  });
                  Navigator.of(context).pop(true);
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  _saveEditedTags();
                  Navigator.of(context).pop(true);
                },
                child: Text('Save'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: CancelButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
