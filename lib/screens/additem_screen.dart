import 'package:flutter/material.dart';
import '../data/classes/list_item.dart';

class AddItemScreen extends StatefulWidget {
  final Function(ListItem) onItemAdded;

  const AddItemScreen({super.key, required this.onItemAdded});

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
              child: FilledButton(
                onPressed: _addItems,
                
                child: Text('Add Items'),
              ),
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

        int count = 1; // Default count to 1
        String name = line;

        // Check if the first part is a number (indicating count)
        if (parts.length > 1 && int.tryParse(parts[0]) != null) {
          count = int.parse(parts[0]);
          name = parts.sublist(1).join(' '); // Join the remaining parts as the name
        }

        // Create a ListItem and add it
        final item = ListItem(name: name, count: count, dateAdded: DateTime.now());

        widget.onItemAdded(item); // Call the callback function to add the item
      }
    }

    Navigator.pop(context); // Go back to the previous screen after adding items
  }
}
