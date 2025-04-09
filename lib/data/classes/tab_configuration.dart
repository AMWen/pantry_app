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
      iconData:
          json['iconData'] ??
          {
            IconDataInfo.iconCodePoint: json['iconCodePoint'] ?? defaultCodePoint,
            IconDataInfo.fontFamily: json['fontFamily'] ?? defaultFontFamily,
            IconDataInfo.fontPackage: defaultFontPackage,
          },
      hasCount: json['hasCount'] ?? false,
      moveTo: json['moveTo'],
      sort: json['sort'],
    );
  }

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

  static List<String> headers = ['Title', 'Item Type', 'Icon Data', 'Has Count', 'Move To', 'Sort'];

  String toCsv() {
    String iconDataString =
        _iconData != null ? _iconData!.entries.map((e) => '${e.key}:${e.value}').join('|') : '';
    return '$title,$itemType,$iconDataString,$_hasCount,${_moveTo ?? ''},${_sort ?? ''}';
  }

  factory TabConfiguration.parseCsvRowToItem(List<String> csvRow) {
    Map<String, dynamic> iconDataMap = {};
    if (csvRow[2].isNotEmpty) {
      var iconDataEntries = csvRow[2].split('|');
      for (var entry in iconDataEntries) {
        var keyValue = entry.split(':');
        if (keyValue.length == 2) {
          var key = keyValue[0];
          var value = keyValue[1];

          if (key == IconDataInfo.iconCodePoint) {
            iconDataMap[key] = int.tryParse(value) ?? defaultCodePoint;
          } else {
            iconDataMap[key] = value;
          }
        }
      }
    }
    int sortValue = int.tryParse(csvRow[5]) ?? DateTime.now().toUtc().millisecondsSinceEpoch;

    return TabConfiguration(
      title: csvRow[0],
      itemType: csvRow[1],
      iconData: iconDataMap, // Assign the map
      hasCount: csvRow[3].toLowerCase() == 'true',
      moveTo: csvRow[4].isNotEmpty ? csvRow[4] : null,
      sort: sortValue,
    );
  }
}
