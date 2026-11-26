import '../models/enums.dart';

class AppImages {
  AppImages._();

  static const String logoIcon = 'assets/icons/logo_icon.png';
  static const String logoWordmark = 'assets/icons/logo_wordmark.png';
  static const String logoFull = 'assets/icons/logo_full.png';

  static const String welcome = 'assets/images/welcome.jpg';
  static const String login = 'assets/images/login.jpg';
  static const String signup = 'assets/images/signup.jpg';

  static const String derivatives = 'assets/images/derivatives.jpg';
  static const String databases = 'assets/images/databases.jpg';
  static const String mobileApp = 'assets/images/mobile_app.jpg';
  static const String developer = 'assets/images/developer.jpg';
  static const String chemistryLab = 'assets/images/chemistry_lab.jpg';
  static const String classroom = 'assets/images/classroom.jpg';

  static const String avatarRodrigo = 'assets/images/avatar_rodrigo.jpg';
  static const String avatarAna = 'assets/images/avatar_ana.jpg';
  static const String avatarInes = 'assets/images/avatar_ines.jpg';
  static const String avatarTiago = 'assets/images/avatar_tiago.jpg';

  /// Fotografias que o estudante pode escolher para um registo, por categoria.
  static const Map<ImageCategory, List<String>> byCategory = {
    ImageCategory.mathematics: [derivatives],
    ImageCategory.databases: [databases],
    ImageCategory.programming: [developer, mobileApp],
    ImageCategory.chemistry: [chemistryLab],
    ImageCategory.study: [classroom, welcome, login, signup],
  };

  /// Imagem usada quando o registo não tem fotografia.
  static String forSubject(Subject subject) {
    return switch (subject) {
      Subject.mathematics => derivatives,
      Subject.databases => databases,
      Subject.mobile => mobileApp,
      Subject.chemistry => chemistryLab,
    };
  }
}
