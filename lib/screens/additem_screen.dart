import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/classes/list_item.dart';
import '../data/classes/tab_configuration.dart';
import '../data/constants.dart';
import '../utils/file_utils.dart';
import '../utils/hivebox_utils.dart';
import '../utils/widget_utils.dart';

class AddItemScreen extends StatefulWidget {
  final String itemType;
  final String boxName;

  const AddItemScreen({super.key, required this.itemType, required this.boxName});

  @override
  AddItemScreenState createState() => AddItemScreenState();
}

class AddItemScreenState extends State<AddItemScreen> {
  final _controller = TextEditingController();
  Box<TabConfiguration> tabBox = getTabConfigurationsBox();
  late bool hasCount;

  @override
  void initState() {
    super.initState();
    hasCount = tabBox.get(widget.boxName)!.hasCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Items')),
      body: Stack(
        // Stack to position the button at the bottom
        children: [
          SingleChildScrollView(
            // Content that can scroll
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: null, // Allow multiline input
                  decoration: InputDecoration(
                    hintText:
                        'Enter items (one per line)${hasCount ? '. Qty of 1 is optional.' : ''}',
                    hintStyle: TextStyles.hintText,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Align(
            // Align the button at the bottom of the screen
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(onPressed: _addItems, child: Text('Add Items')),
            ),
          ),
        ],
      ),
    );
  }

  void _addItems() async {
    final itemBox = Hive.box<ListItem>(widget.boxName);
    final inputText = _controller.text.trim();
    final lines = inputText.split('\n').map((line) => line.trim()).toList();

    for (var line in lines) {
      if (line.isNotEmpty) {
        final parts = line.split(' ');

        int count = 1;
        String name = line;

        // If hasCount is true and the first part is a number, adjust count and name
        if (hasCount && parts.length > 1 && int.tryParse(parts[0]) != null) {
          count = int.parse(parts[0]);
          name = parts.sublist(1).join(' '); // Join the remaining parts as the name
        }

        final item = ListItem(
          name: name,
          count: count,
          dateAdded: DateTime.now(),
          itemType: widget.itemType,
        );
        itemBox.add(item);
      }
    }
    if (inputText.isNotEmpty) {
      setLastUpdated(widget.boxName);
      String? message = await autoSave(widget.boxName);
      if (message != null) {
        if (mounted) {
          showErrorSnackbar(context, message);
        }
      }
    }
    if (mounted) {
      Navigator.pop(context); // Go back to the previous screen after adding items
    }
  }
}
