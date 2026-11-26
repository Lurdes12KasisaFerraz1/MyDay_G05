/// Pesquisa simples que ignora maiúsculas e acentos ("calculo" encontra "Cálculo").
class TextSearch {
  TextSearch._();

  static const Map<String, String> _accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a',
    'é': 'e', 'ê': 'e',
    'í': 'i',
    'ó': 'o', 'ô': 'o', 'õ': 'o',
    'ú': 'u',
    'ç': 'c',
  };

  static String normalize(String text) {
    final lower = text.toLowerCase().trim();
    return lower.split('').map((char) => _accents[char] ?? char).join();
  }

  /// true se a [query] aparecer em algum dos [fields].
  static bool matches(String query, Iterable<String> fields) {
    final needle = normalize(query);
    if (needle.isEmpty) return false;
    return fields.any((field) => normalize(field).contains(needle));
  }
}
