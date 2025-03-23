import 'package:flutter/material.dart';

class TabItem {
  final Widget screen;
  final Icon icon;
  final String label;
  final String itemType;
  final String boxName;

  TabItem({
    required this.screen,
    required this.icon,
    required this.label,
    required this.itemType,
    required this.boxName,
  });
}
