// Displays filepath in condensed and expanded forms

import 'package:flutter/material.dart';

class FileLocationWidget extends StatefulWidget {
  final String boxName;
  final String fileLocation;

  const FileLocationWidget({super.key, required this.boxName, required this.fileLocation});

  @override
  FileLocationWidgetState createState() => FileLocationWidgetState();
}

class FileLocationWidgetState extends State<FileLocationWidget> {
  late ScrollController _scrollController;
  bool _isFullLocationVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Function to get the shortened version of the file location
  String _getShortenedFileLocation(String fileLocation) {
    if (fileLocation.contains('/')) {
      final fileName = fileLocation.split('/').last; // Get the last part (file name)
      final directory = fileLocation.substring(
        0,
        fileLocation.lastIndexOf('/'),
      );

      return directory.length > 20 ? '.../$fileName' : fileLocation;
    } else {
      return fileLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current file location (either full or shortened based on the state)
    final displayFileLocation =
        _isFullLocationVisible
            ? widget.fileLocation
            : _getShortenedFileLocation(widget.fileLocation);

    return Row(
      children: [
        Text(
          '${widget.boxName}: ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), // Bold for boxName
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFullLocationVisible = !_isFullLocationVisible;
              });
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Text(
                displayFileLocation,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
