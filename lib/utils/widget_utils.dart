import 'package:flutter/material.dart';

import '../data/constants.dart';

void showErrorSnackbar(BuildContext context, String message) {
  Duration duration =
      message.contains('Error') ? Duration(milliseconds: 1500) : Duration(milliseconds: 800);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: duration));
}

List<Widget> generateListTiles(
  BuildContext context,
  List<Map<String, dynamic>> actions, [
  bool pop = true,
]) {
  return actions.map((action) {
    return ListTile(
      minTileHeight: 10,
      leading: action['leading'],
      title: Text(action['title'], style: TextStyles.mediumText),
      onTap: () {
        pop ? Navigator.of(context).pop() : null;
        action['action']();
      },
    );
  }).toList();
}
