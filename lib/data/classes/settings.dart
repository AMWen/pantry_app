import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
  @HiveField(0)
  String boxName;

  @HiveField(1)
  String? _fileLocation;

  Settings({required this.boxName, String? fileLocation}) : _fileLocation = fileLocation;

  String? get fileLocation => _fileLocation;

  set fileLocation(String? location) {
    _fileLocation = location;
    save(); // Automatically save after setting the file location
  }
}