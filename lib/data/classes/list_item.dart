import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../utils/string_utils.dart';

part 'list_item.g.dart'; // build with flutter pub run build_runner build
// needed to edit this portion: itemType: fields[5] != null ? fields[5] as String : 'pantry'

@HiveType(typeId: 0)
class ListItem<T> extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int? count;

  @HiveField(2)
  DateTime dateAdded;

  @HiveField(3)
  String? tag;

  @HiveField(4)
  bool? completed;

  @HiveField(5)
  String itemType;

  ListItem({
    required this.name,
    this.count,
    required this.dateAdded,
    this.tag,
    this.completed = false,
    this.itemType = 'pantry',
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      name: json['name'],
      count: json['count'],
      dateAdded: DateTime.parse(json['dateAdded']),
      tag: json['tag'],
      completed: json['completed'] ?? false,
      itemType: json['itemType'] ?? 'pantry',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'dateAdded': dateAdded.toIso8601String(),
      'tag': tag,
      'completed': completed,
      'itemType': itemType,
    };
  }

  // Helper method to get the color for the tag
  Color itemTagColor() {
    return getTagColor(tag, itemType);
  }
}
