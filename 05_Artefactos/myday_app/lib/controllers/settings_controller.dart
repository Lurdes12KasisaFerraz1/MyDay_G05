import 'package:flutter/foundation.dart';

class SettingsController extends ChangeNotifier {
  bool _locationEnabled = true;
  bool _microphoneEnabled = false;
  bool _remindersEnabled = true;

  bool get locationEnabled => _locationEnabled;
  bool get microphoneEnabled => _microphoneEnabled;
  bool get remindersEnabled => _remindersEnabled;

  void setLocation(bool value) {
    _locationEnabled = value;
    notifyListeners();
  }

  void setMicrophone(bool value) {
    _microphoneEnabled = value;
    notifyListeners();
  }

  void setReminders(bool value) {
    _remindersEnabled = value;
    notifyListeners();
  }
}
