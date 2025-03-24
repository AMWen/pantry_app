import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/file_utils.dart';
import '../classes/list_item.dart';
import '../constants.dart';
import 'basic_widgets.dart';
import '../../utils/snackbar_util.dart';

class EditDialog extends StatefulWidget {
  final ListItem item;
  final bool hasCount;
  final String boxName;

  const EditDialog({super.key, required this.item, required this.boxName, this.hasCount = false});

  @override
  EditDialogState createState() => EditDialogState();
}

class EditDialogState extends State<EditDialog> {
  late TextEditingController qtyController;
  late TextEditingController nameController;
  late TextEditingController dateController;
  late TextEditingController urlController;

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController(text: widget.item.count.toString());
    nameController = TextEditingController(text: widget.item.name);
    dateController = TextEditingController(text: dateFormat.format(widget.item.dateAdded));
    urlController = TextEditingController(text: widget.item.url);
  }

  @override
  void dispose() {
    qtyController.dispose();
    nameController.dispose();
    dateController.dispose();
    urlController.dispose();
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
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  border: InputBorder.none,
                ),
              ),
            if (widget.hasCount) SizedBox(height: 2),
            TextField(
              controller: nameController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Item',
                hintText: 'Enter the new item',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 2),
            TextField(
              controller: dateController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Date Added',
                hintText: 'Enter the new date',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'URL',
                      hintText: 'Enter the URL',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    final url = urlController.text;
                    if (url.isNotEmpty) {
                      _launchUrl(url);
                    } else {
                      showErrorSnackbar(context, 'No URL to go to');
                    }
                  },
                  color: primaryColor,
                ),
              ],
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
            widget.item.url = urlController.text;
            try {
              DateTime dateTime = dateFormat.parse(dateController.text);
              widget.item.dateAdded = dateTime;
            } catch (e) {
              showErrorSnackbar(context, 'Invalid date, not updating');
            }
            if (widget.hasCount) {
              try {
                int qty = int.parse(qtyController.text);
                widget.item.count = qty;
              } catch (e) {
                showErrorSnackbar(context, 'Invalid quantity, not updating');
              }
            }
            widget.item.save();
            autoSave(widget.boxName);
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
