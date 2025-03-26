import 'package:hive/hive.dart';

part 'tab_configuration.g.dart';

@HiveType(typeId: 2)
class TabConfiguration {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String itemType;
  @HiveField(2)
  final int iconCodePoint;
  @HiveField(3)
  final bool hasCount;
  @HiveField(4)
  final String? moveTo;

  TabConfiguration({
    required this.title,
    required this.itemType,
    required this.iconCodePoint,
    required this.hasCount,
    this.moveTo,
  });
}
