import 'dart:math';

import '../models/enums.dart';

/// Gera e confirma os códigos de 6 dígitos enviados por email ou SMS.
///
/// Ainda não há servidor para enviar mensagens reais, por isso [send] devolve
/// o código e a app mostra-o num aviso de demonstração. Com backend, o código
/// passa a ser gerado e enviado no servidor e esta classe só o confirma.
class VerificationService {
  static const Duration validity = Duration(minutes: 10);

  final Random _random = Random.secure();
  final Map<String, _IssuedCode> _codes = {};

  String send({
    required VerificationPurpose purpose,
    required String email,
    required VerificationChannel channel,
  }) {
    final code = List.generate(6, (_) => _random.nextInt(10)).join();
    _codes[_key(purpose, email)] = _IssuedCode(code, DateTime.now().add(validity));
    return code;
  }

  /// Devolve true se o código estiver certo e dentro do prazo. Cada código só
  /// pode ser usado uma vez.
  bool verify({
    required VerificationPurpose purpose,
    required String email,
    required String code,
  }) {
    final key = _key(purpose, email);
    final issued = _codes[key];
    if (issued == null || DateTime.now().isAfter(issued.expiresAt)) {
      _codes.remove(key);
      return false;
    }
    if (issued.code != code.trim()) return false;

    _codes.remove(key);
    return true;
  }

  String _key(VerificationPurpose purpose, String email) => '${purpose.name}:${email.trim().toLowerCase()}';
}

class _IssuedCode {
  const _IssuedCode(this.code, this.expiresAt);

  final String code;
  final DateTime expiresAt;
}
