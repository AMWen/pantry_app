import 'package:hive/hive.dart';

import '../constants.dart';

part 'tab_configuration.g.dart';

@HiveType(typeId: 2)
class TabConfiguration extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String itemType;
  @HiveField(2)
  int _iconCodePoint;
  @HiveField(3)
  bool _hasCount;
  @HiveField(4)
  String? _moveTo;
  @HiveField(5)
  DateTime? _timestamp;

  TabConfiguration({
    required this.title,
    required this.itemType,
    int? iconCodePoint,
    bool hasCount = false,
    String? moveTo,
    DateTime? timestamp,
  }) : _iconCodePoint = iconCodePoint ?? defaultCodePoint,
       _hasCount = hasCount,
       _moveTo = moveTo,
       _timestamp = timestamp ?? DateTime.now().toUtc();

  int get iconCodePoint => _iconCodePoint;
  set iconCodePoint(int value) {
    _iconCodePoint = value;
    save();
  }

  bool get hasCount => _hasCount;
  set hasCount(bool value) {
    _hasCount = value;
    save();
  }

  String? get moveTo => _moveTo;
  set moveTo(String? value) {
    _moveTo = value;
    save();
  }

  DateTime get timestamp => _timestamp ?? defaultDateTime;
  set timestamp(DateTime value) {
    _timestamp = value;
    save();
  }
}
