import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  String boxName;

  @HiveField(1)
  String? _fileLocation;

  @HiveField(2)
  DateTime? lastUpdated;

  Settings({required this.boxName, String? fileLocation, this.lastUpdated})
      : _fileLocation = fileLocation;

  String? get fileLocation => _fileLocation;

  set fileLocation(String? location) {
    _fileLocation = location;
    save();
  }

  void updateLastUpdated() {
    lastUpdated = DateTime.now();
    save();
  }
}