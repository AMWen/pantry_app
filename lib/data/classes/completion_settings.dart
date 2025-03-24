import 'package:hive/hive.dart';

part 'completion_settings.g.dart';

@HiveType(typeId: 2)
class CompletionSettings extends HiveObject {
  @HiveField(0)
  String boxName;

  @HiveField(1)
  bool _showCompleted = true;

  @HiveField(2)
  bool _selectAllCompleted = false;

  CompletionSettings({
    required this.boxName,
    bool showCompleted = true,
    bool selectAllCompleted = false,
  })  : _showCompleted = showCompleted,
        _selectAllCompleted = selectAllCompleted;

  bool get showCompleted => _showCompleted;

  set showCompleted(bool value) {
    _showCompleted = value;
    save();  // Persist changes when the value is updated
  }

  bool get selectAllCompleted => _selectAllCompleted;

  set selectAllCompleted(bool value) {
    _selectAllCompleted = value;
    save();  // Persist changes when the value is updated
  }
}
