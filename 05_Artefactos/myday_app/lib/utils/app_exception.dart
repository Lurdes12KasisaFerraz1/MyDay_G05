/// Erro previsto que deve ser mostrado ao utilizador num popup.
class AppException implements Exception {
  const AppException(this.message, {this.title = 'Algo correu mal'});

  final String title;
  final String message;

  @override
  String toString() => message;
}
