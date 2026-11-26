import 'package:flutter_test/flutter_test.dart';
import 'package:myday_app/controllers/auth_controller.dart';
import 'package:myday_app/controllers/diary_controller.dart';
import 'package:myday_app/controllers/project_controller.dart';
import 'package:myday_app/models/enums.dart';
import 'package:myday_app/services/data_service.dart';
import 'package:myday_app/utils/validators.dart';

void main() {
  group('Validators', () {
    test('rejeita email sem domínio completo', () {
      expect(Validators.email('ana.lopes@iade'), isNotNull);
      expect(Validators.email('ana.lopes@iade.pt'), isNull);
    });

    test('exige palavra-passe com pelo menos 6 caracteres', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('estudar2026'), isNull);
    });
  });

  group('AuthController', () {
    test('entra com credenciais válidas', () {
      final auth = AuthController(DataService());

      expect(auth.login('rodrigo@iade.pt', 'myday2026'), isNull);
      expect(auth.currentUser?.firstName, 'Rodrigo');
    });

    test('não cria duas contas com o mesmo email', () {
      final auth = AuthController(DataService());

      final error = auth.register(
        name: 'Outro',
        email: 'rodrigo@iade.pt',
        password: 'segredo123',
        course: 'Design · IADE',
      );
      expect(error, isNotNull);
    });
  });

  group('DiaryController', () {
    test('um novo registo aparece nos registos de hoje', () {
      final diary = DiaryController(DataService());
      final before = diary.todayEntries.length;

      diary.addEntry(
        title: 'Joins em SQL',
        text: 'Junções no WHERE.',
        subject: Subject.databases,
        project: 'Bases de Dados',
        visibility: EntryVisibility.private,
        tags: const ['sql'],
      );

      expect(diary.todayEntries.length, before + 1);
      expect(diary.todayEntries.first.title, 'Joins em SQL');
    });
  });

  group('ProjectController', () {
    test('filtra os projetos pela visibilidade', () {
      final projects = ProjectController(DataService());

      projects.setFilter(EntryVisibility.public);

      expect(projects.projects, isNotEmpty);
      expect(projects.projects.every((p) => p.visibility == EntryVisibility.public), isTrue);
    });
  });
}
