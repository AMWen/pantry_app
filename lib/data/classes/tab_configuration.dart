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
  @HiveField(6)
  int? _sort;
  @HiveField(7)
  String? _fontFamily;
  
  TabConfiguration({
    required this.title,
    required this.itemType,
    int? iconCodePoint,
    bool hasCount = false,
    String? moveTo,
    int? sort,
    String? fontFamily,
  }) : _iconCodePoint = iconCodePoint ?? defaultCodePoint,
       _fontFamily = fontFamily ?? defaultFontFamily,
       _hasCount = hasCount,
       _moveTo = moveTo,
       _sort = sort ?? DateTime.now().toUtc().millisecondsSinceEpoch;

  int get iconCodePoint => _iconCodePoint;
  set iconCodePoint(int value) {
    _iconCodePoint = value;
    save();
  }

  String get fontFamily => _fontFamily ?? defaultFontFamily;
  set fontFamily(String value) {
    _fontFamily = value;
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

  int get sort => _sort ?? defaultDateTime.millisecondsSinceEpoch;
  set sort(int value) {
    _sort = value;
    save();
  }

  factory TabConfiguration.fromJson(Map<String, dynamic> json) {
    return TabConfiguration(
      title: json['title'],
      itemType: json['itemType'],
      iconCodePoint: json['iconCodePoint'] ?? defaultCodePoint,
      hasCount: json['hasCount'] ?? false,
      moveTo: json['moveTo'],
      sort: json['sort'],
    );
  }

  // toJson to convert TabConfiguration object to a Map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'itemType': itemType,
      'iconCodePoint': _iconCodePoint,
      'hasCount': _hasCount,
      'moveTo': _moveTo,
      'sort': _sort,
    };
  }
}
