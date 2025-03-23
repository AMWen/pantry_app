import 'package:flutter/material.dart';

import '../classes/list_item.dart';
import '../constants.dart';
import 'basic_widgets.dart';

class EditDialog extends StatefulWidget {
  final ListItem item;
  final bool hasCount;

  const EditDialog({super.key, required this.item, this.hasCount = false});

  @override
  EditDialogState createState() => EditDialogState();
}

class EditDialogState extends State<EditDialog> {
  late TextEditingController qtyController;
  late TextEditingController nameController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController(text: widget.item.count.toString());
    nameController = TextEditingController(text: widget.item.name);
    dateController = TextEditingController(text: dateFormat.format(widget.item.dateAdded));
  }

  @override
  void dispose() {
    qtyController.dispose();
    nameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: Duration(milliseconds: 700)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AlertTitle('Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.hasCount)
              TextField(
                controller: qtyController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter the new quantity',
                ),
              ),
            TextField(
              controller: nameController,
              maxLines: null,
              decoration: InputDecoration(labelText: 'Item', hintText: 'Enter the new item'),
            ),
            TextField(
              controller: dateController,
              maxLines: null,
              decoration: InputDecoration(labelText: 'Date Added', hintText: 'Enter the new date'),
            ),
          ],
        ),
      ),
      actions: [
        CancelButton(),
        FilledButton(
          onPressed: () {
            // Handle saving the data
            widget.item.name = nameController.text;
            try {
              DateTime dateTime = dateFormat.parse(dateController.text);
              widget.item.dateAdded = dateTime;
            } catch (e) {
              showErrorSnackbar('Invalid date, not updating');
            }
            if (widget.hasCount) {
              try {
                int qty = int.parse(qtyController.text);
                widget.item.count = qty;
              } catch (e) {
                showErrorSnackbar('Invalid quantity, not updating');
              }
            }
            widget.item.save();
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
