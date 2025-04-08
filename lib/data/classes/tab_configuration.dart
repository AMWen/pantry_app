import 'package:hive/hive.dart';

import '../constants.dart';

part 'tab_configuration.g.dart';

@HiveType(typeId: 2)
class TabConfiguration extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String itemType;
  @HiveField(3)
  bool _hasCount;
  @HiveField(4)
  String? _moveTo;
  @HiveField(6)
  int? _sort;
  @HiveField(8)
  Map<String, dynamic>? _iconData;

  TabConfiguration({
    required this.title,
    required this.itemType,
    int? iconCodePoint,
    bool hasCount = false,
    String? moveTo,
    int? sort,
    String? fontFamily,
    Map<String, dynamic>? iconData,
  }) : _iconData =
           iconData ??
           {
             IconDataInfo.iconCodePoint: iconCodePoint ?? defaultCodePoint,
             IconDataInfo.fontFamily: fontFamily ?? defaultFontFamily,
             IconDataInfo.fontPackage: defaultFontPackage,
           },
       _hasCount = hasCount,
       _moveTo = moveTo,
       _sort = sort ?? DateTime.now().toUtc().millisecondsSinceEpoch;

  Map<String, dynamic> get iconData => _iconData ?? defaultIconData;
  set iconData(Map<String, dynamic> value) {
    _iconData = value;
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
      iconData: json['iconData'] ?? defaultIconData,
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
      'iconData': _iconData,
      'hasCount': _hasCount,
      'moveTo': _moveTo,
      'sort': _sort,
    };
  }
}
