import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../utils/string_utils.dart';

part 'pantry_item.g.dart'; // build with flutter pub run build_runner build

@HiveType(typeId: 0)
class PantryItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int count;

  @HiveField(2)
  DateTime dateAdded;

  @HiveField(3)
  String? tag;

  PantryItem({required this.name, required this.count, required this.dateAdded, this.tag});

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      name: json['name'],
      count: json['count'],
      dateAdded: DateTime.parse(json['dateAdded']),
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'dateAdded': dateAdded.toIso8601String(), 'tag': tag};
  }

  // Helper method to get the color for the tag
  Color itemTagColor() {
    return getTagColor(tag);
  }
}
