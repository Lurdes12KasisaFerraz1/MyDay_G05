import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/data_service.dart';
import '../utils/app_images.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._dataService);

  final DataService _dataService;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Devolve uma mensagem de erro, ou null se a sessão foi iniciada.
  String? login(String email, String password) {
    final user = _dataService.findUser(email, password);
    if (user == null) {
      return 'Email ou palavra-passe incorretos.';
    }
    _currentUser = user;
    notifyListeners();
    return null;
  }

  /// Devolve uma mensagem de erro, ou null se a conta foi criada.
  String? register({
    required String name,
    required String email,
    required String password,
    required String course,
  }) {
    if (_dataService.emailExists(email)) {
      return 'Já existe uma conta com este email.';
    }
    final user = User(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      course: course,
      avatarPath: AppImages.avatarAna,
    );
    _dataService.addUser(user);
    _currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
