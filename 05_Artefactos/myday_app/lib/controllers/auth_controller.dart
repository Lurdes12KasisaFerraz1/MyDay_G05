import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../services/verification_service.dart';
import '../utils/app_exception.dart';
import '../utils/app_images.dart';

/// Código enviado ao utilizador e que ainda falta confirmar.
class PendingVerification {
  const PendingVerification({
    required this.purpose,
    required this.user,
    required this.channel,
    required this.demoCode,
  });

  final VerificationPurpose purpose;
  final User user;
  final VerificationChannel channel;

  /// Só existe porque ainda não há envio real de emails e SMS.
  final String demoCode;

  String get destination {
    return switch (channel) {
      VerificationChannel.email => _maskEmail(user.email),
      VerificationChannel.sms => '*** *** ${user.phone.substring(user.phone.length - 3)}',
    };
  }

  static String _maskEmail(String email) {
    final at = email.indexOf('@');
    return '${email[0]}***${email.substring(at)}';
  }
}

class AuthController extends ChangeNotifier {
  AuthController(this._dataService, this._verificationService);

  static const int maxLoginAttempts = 3;

  final DataService _dataService;
  final VerificationService _verificationService;

  User? _currentUser;
  PendingVerification? _pending;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  PendingVerification? get pendingVerification => _pending;

  /// Primeiro passo do login: confirma a palavra-passe e envia o código do
  /// segundo fator. Ao fim de [maxLoginAttempts] falhas a conta fica bloqueada.
  void startLogin(String email, String password) {
    final user = _dataService.findUserByEmail(email);
    if (user == null) {
      throw const AppException('Email ou palavra-passe incorretos.', title: 'Não foi possível entrar');
    }
    if (_isLocked(user)) throw _lockedError;

    if (user.password != password) {
      user.failedLoginAttempts++;
      if (_isLocked(user)) throw _lockedError;

      final left = maxLoginAttempts - user.failedLoginAttempts;
      throw AppException(
        left == 1 ? 'Palavra-passe incorreta. Tens mais 1 tentativa.' : 'Palavra-passe incorreta. Tens mais $left tentativas.',
        title: 'Não foi possível entrar',
      );
    }

    _sendCode(VerificationPurpose.login, user, VerificationChannel.email);
  }

  /// Primeiro passo do registo: a conta só é criada depois de confirmar o código.
  void startRegistration({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String course,
    required VerificationChannel channel,
  }) {
    if (_dataService.emailExists(email)) {
      throw const AppException('Já existe uma conta com este email.', title: 'Conta já existe');
    }
    final user = User(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      phone: phone.replaceAll(' ', ''),
      course: course,
      avatarPath: AppImages.avatarAna,
    );
    _sendCode(VerificationPurpose.signup, user, channel);
  }

  void resendCode(VerificationChannel channel) {
    final pending = _pending;
    if (pending == null) return;
    _sendCode(pending.purpose, pending.user, channel);
  }

  /// Confirma o código do registo ou do login e inicia a sessão.
  void confirmCode(String code) {
    final pending = _pending;
    if (pending == null) {
      throw const AppException('O pedido expirou. Volta a começar.');
    }

    final isValid = _verificationService.verify(purpose: pending.purpose, email: pending.user.email, code: code);
    if (!isValid) {
      if (pending.purpose == VerificationPurpose.login) {
        pending.user.failedLoginAttempts++;
        if (_isLocked(pending.user)) {
          _pending = null;
          throw _lockedError;
        }
      }
      throw const AppException('O código está errado ou já expirou.', title: 'Código inválido');
    }

    if (pending.purpose == VerificationPurpose.signup) {
      _dataService.addUser(pending.user);
    }
    pending.user.failedLoginAttempts = 0;
    _currentUser = pending.user;
    _pending = null;
    notifyListeners();
  }

  void requestPasswordReset(String email) {
    final user = _dataService.findUserByEmail(email);
    if (user == null) {
      throw const AppException('Não existe nenhuma conta com este email.', title: 'Conta não encontrada');
    }
    _sendCode(VerificationPurpose.passwordReset, user, VerificationChannel.email);
  }

  /// Muda a palavra-passe e desbloqueia a conta.
  void resetPassword(String code, String newPassword) {
    final pending = _pending;
    if (pending == null || pending.purpose != VerificationPurpose.passwordReset) {
      throw const AppException('O pedido expirou. Pede um novo código.');
    }
    final isValid = _verificationService.verify(
      purpose: VerificationPurpose.passwordReset,
      email: pending.user.email,
      code: code,
    );
    if (!isValid) {
      throw const AppException('O código está errado ou já expirou.', title: 'Código inválido');
    }

    pending.user
      ..password = newPassword
      ..failedLoginAttempts = 0;
    _pending = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _pending = null;
    notifyListeners();
  }

  static const AppException _lockedError = AppException(
    'Falhaste $maxLoginAttempts tentativas seguidas. Para desbloquear a conta, recupera a palavra-passe.',
    title: 'Conta bloqueada',
  );

  bool _isLocked(User user) => user.failedLoginAttempts >= maxLoginAttempts;

  void _sendCode(VerificationPurpose purpose, User user, VerificationChannel channel) {
    final code = _verificationService.send(purpose: purpose, email: user.email, channel: channel);
    _pending = PendingVerification(purpose: purpose, user: user, channel: channel, demoCode: code);
    notifyListeners();
  }
}
