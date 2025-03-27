import 'package:hive/hive.dart';

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

  TabConfiguration({
    required this.title,
    required this.itemType,
    int iconCodePoint = 0,
    bool hasCount = false,
    String? moveTo,
  }) : _iconCodePoint = iconCodePoint,
       _hasCount = hasCount,
       _moveTo = moveTo;

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
}
