import 'package:flutter/material.dart';
import '../data/classes/list_item.dart';

class AddItemScreen extends StatefulWidget {
  final Function(ListItem) onItemAdded;
  final String itemType;
  final bool hasCount;

  const AddItemScreen({super.key, required this.onItemAdded, required this.itemType, this.hasCount = true});

  @override
  AddItemScreenState createState() => AddItemScreenState();
}

class AddItemScreenState extends State<AddItemScreen> {
  final _controller = TextEditingController();

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
                    hintText: 'Enter items (one per line)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                // The rest of your content can go here
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

  void _addItems() {
    final inputText = _controller.text.trim();
    final lines = inputText.split('\n').map((line) => line.trim()).toList();

    for (var line in lines) {
      if (line.isNotEmpty) {
        final parts = line.split(' ');

        int count = widget.hasCount ? 1 : 0; // Default count to 1 if hasCount is true, otherwise 0
        String name = line;

        // If hasCount is true and the first part is a number, adjust count and name
        if (widget.hasCount && parts.length > 1 && int.tryParse(parts[0]) != null) {
          count = int.parse(parts[0]);
          name = parts.sublist(1).join(' '); // Join the remaining parts as the name
        }

        // Create the ListItem, either with or without count
        final item = ListItem(
          name: name,
          count: widget.hasCount ? count : null, // Only assign count if hasCount is true
          dateAdded: DateTime.now(),
          itemType: widget.itemType,
        );

        widget.onItemAdded(item); // Call the callback function to add the item
      }

      Navigator.pop(context); // Go back to the previous screen after adding items
    }
  }
}
