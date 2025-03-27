import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../utils/string_utils.dart';

part 'list_item.g.dart'; // build with dart run build_runner build

@HiveType(typeId: 0)
class ListItem<T> extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int? _count;

  @HiveField(2)
  DateTime dateAdded;

  @HiveField(3)
  String? tag;

  @HiveField(4)
  bool? completed;

  @HiveField(5)
  String itemType;

  @HiveField(6)
  String? url;

  @HiveField(7)
  String? notes;

  ListItem({
    required this.name,
    int? count = 1,
    required this.dateAdded,
    this.tag,
    this.completed = false,
    this.itemType = 'pantry',
    this.url,
    this.notes,
  }) : _count = count ?? 1;

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      name: json['name'],
      count: json['count'] ?? 1,
      dateAdded: DateTime.parse(json['dateAdded']),
      tag: json['tag'],
      completed: json['completed'] ?? false,
      itemType: json['itemType'] ?? 'pantry',
      url: json['url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': _count ?? 1,
      'dateAdded': dateAdded.toIso8601String(),
      'tag': tag,
      'completed': completed,
      'itemType': itemType,
      'url': url,
      'notes': notes,
    };
  }

  int get count => _count ?? 1;
  set count(int value) {
    _count = value;
    save();
  }

  // Helper method to get the color for the tag
  Color itemTagColor(options) {
    return getTagColor(tag, options);
  }
}
