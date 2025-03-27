import 'package:flutter/material.dart';

import '../data/constants.dart';

void showErrorSnackbar(BuildContext context, String message) {
  Duration duration =
      message.contains('Error') ? Duration(milliseconds: 1500) : Duration(milliseconds: 700);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: duration));
}

List<Widget> generateListTiles(BuildContext context, List<Map<String, dynamic>> actions) {
  return actions.map((action) {
    return ListTile(
      minTileHeight: 10,
      title: Text(action['title'], style: TextStyles.mediumText),
      onTap: () {
        Navigator.of(context).pop();
        action['action']();
      },
    );
  }).toList();
}
