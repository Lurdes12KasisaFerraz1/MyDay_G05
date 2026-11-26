class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escreve o teu nome';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escreve o teu email';
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Falta o domínio completo, por exemplo nome@iade.pt';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'A palavra-passe precisa de pelo menos 6 caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Repete a palavra-passe';
    }
    if (value != password) {
      return 'As palavras-passe não coincidem';
    }
    return null;
  }

  /// Número de telemóvel português: 9 dígitos a começar por 9.
  static String? phone(String? value) {
    final digits = value?.replaceAll(RegExp(r'\s'), '') ?? '';
    if (digits.isEmpty) {
      return 'Escreve o teu número de telemóvel';
    }
    if (!RegExp(r'^9\d{8}$').hasMatch(digits)) {
      return 'Número inválido, por exemplo 912 345 678';
    }
    return null;
  }

  static String? verificationCode(String? value) {
    if (value == null || !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'O código tem 6 dígitos';
    }
    return null;
  }

  static String? requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Devolve um valor entre 0 e 4 conforme a variedade de caracteres.
  static int passwordStrength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score;
  }
}
