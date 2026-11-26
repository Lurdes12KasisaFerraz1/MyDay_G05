import 'enums.dart';

/// Projeto do estudante (tabela projeto). O número de registos e a última
/// atividade são calculados a partir das notas, por isso não ficam aqui.
class Project {
  const Project({
    required this.name,
    required this.coverImage,
    required this.visibility,
    required this.subject,
    required this.description,
  });

  final String name;
  final String coverImage;
  final EntryVisibility visibility;

  /// Disciplina do projeto (prj_dis_id). Os registos do projeto herdam-na.
  final Subject subject;
  final String description;
}
