import 'dart:async';
import '../../utils/file_utils.dart';

class AutoLoadService {
  late Timer _autoLoadTimer;

  void startAutoLoad(String boxName, {Function(String)? showErrorSnackbar}) {
    autoLoad(boxName, showErrorSnackbar: showErrorSnackbar);
    _autoLoadTimer = Timer.periodic(Duration(minutes: 5), (_) {
      autoLoad(boxName, showErrorSnackbar: showErrorSnackbar);
    });
  }

  void stopAutoLoad() {
    _autoLoadTimer.cancel();
  }
}
