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
