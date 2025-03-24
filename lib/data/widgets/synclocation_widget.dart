// Displays filepath for sync in condensed and expanded forms

import 'package:flutter/material.dart';

class SyncLocationWidget extends StatefulWidget {
  final String boxName;
  final String syncLocation;

  const SyncLocationWidget({super.key, required this.boxName, required this.syncLocation});

  @override
  SyncLocationWidgetState createState() => SyncLocationWidgetState();
}

class SyncLocationWidgetState extends State<SyncLocationWidget> {
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
  String _getShortenedSyncLocation(String syncLocation) {
    if (syncLocation.contains('/')) {
      final fileName = syncLocation.split('/').last; // Get the last part (file name)
      final directory = syncLocation.substring(
        0,
        syncLocation.lastIndexOf('/'),
      );

      return directory.length > 20 ? '.../$fileName' : syncLocation;
    } else {
      return syncLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current file location (either full or shortened based on the state)
    final displaySyncLocation =
        _isFullLocationVisible
            ? widget.syncLocation
            : _getShortenedSyncLocation(widget.syncLocation);

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
                displaySyncLocation,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
