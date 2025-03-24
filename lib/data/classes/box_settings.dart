import 'package:hive/hive.dart';

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

  BoxSettings({
    required this.boxName,
    String? syncLocation,
    this.lastUpdated,
    bool showCompleted = true,
    bool selectAllCompleted = false,
  }) : _syncLocation = syncLocation,
       _showCompleted = showCompleted,
       _selectAllCompleted = selectAllCompleted;

  String? get syncLocation => _syncLocation;
  bool get showCompleted => _showCompleted;
  bool get selectAllCompleted => _selectAllCompleted;

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
    save(); // Persist changes when the value is updated
  }

  set selectAllCompleted(bool value) {
    _selectAllCompleted = value;
    save(); // Persist changes when the value is updated
  }

  factory BoxSettings.fromJson(Map<String, dynamic> json) {
    return BoxSettings(
      boxName: json['boxName'],
      syncLocation: json['syncLocation'],
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      showCompleted: json['showCompleted'] ?? true,
      selectAllCompleted: json['selectAllCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boxName': boxName,
      'syncLocation': _syncLocation,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'showCompleted': _showCompleted,
      'selectAllCompleted': _selectAllCompleted,
    };
  }
}
