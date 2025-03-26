import 'package:hive/hive.dart';
import '../constants.dart';

part 'box_settings.g.dart';

@HiveType(typeId: 1)
class BoxSettings extends HiveObject {
  @HiveField(0)
  String boxName;

  @HiveField(1)
  String? _syncLocation;

  @HiveField(2)
  DateTime? lastUpdated;

  @HiveField(3)
  bool _showCompleted = true;

  @HiveField(4)
  bool _selectAllCompleted = false;

  @HiveField(5)
  List<String>? _tags;

  @HiveField(6)
  String? _sortCriteria;

  BoxSettings({
    required this.boxName,
    String? syncLocation,
    this.lastUpdated,
    bool showCompleted = true,
    bool selectAllCompleted = false,
    List<String>? tags,
    String? sortCriteria,
  }) : _syncLocation = syncLocation,
       _showCompleted = showCompleted,
       _selectAllCompleted = selectAllCompleted,
       _tags = tags ?? defaultTagMapping[defaultItemTypesFromConfigurations()[boxName]] ?? [''],
       _sortCriteria = sortCriteria ?? '';

  String? get syncLocation => _syncLocation;
  bool get showCompleted => _showCompleted;
  bool get selectAllCompleted => _selectAllCompleted;
  List<String> get tags => _tags ?? [''];
  String get sortCriteria => _sortCriteria ?? '';

  set syncLocation(String? location) {
    _syncLocation = location;
    save();
  }

  void updateLastUpdated() {
    lastUpdated = DateTime.now();
    save();
  }

  set showCompleted(bool value) {
    _showCompleted = value;
    save();
  }

  set selectAllCompleted(bool value) {
    _selectAllCompleted = value;
    save();
  }

  set tags(List<String> value) {
    _tags = value;
    save();
  }

  set sortCriteria(String value) {
    _sortCriteria = value;
    save();
  }

  void resetTags() {
    _tags = defaultTagMapping[defaultItemTypesFromConfigurations()[boxName]] ?? [''];
    save();
  }

  factory BoxSettings.fromJson(Map<String, dynamic> json) {
    return BoxSettings(
      boxName: json['boxName'],
      syncLocation: json['syncLocation'],
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      showCompleted: json['showCompleted'] ?? true,
      selectAllCompleted: json['selectAllCompleted'] ?? false,
      tags: List<String>.from(
        json['tags'] ??
            defaultTagMapping[defaultItemTypesFromConfigurations()[json['boxName']]] ??
            [''],
      ),
      sortCriteria: json['sortCriteria'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boxName': boxName,
      'syncLocation': _syncLocation,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'showCompleted': _showCompleted,
      'selectAllCompleted': _selectAllCompleted,
      'tags': _tags,
      'sortCriteria': _sortCriteria,
    };
  }
}
