import 'package:flutter_test/flutter_test.dart';
import 'package:myday_app/controllers/auth_controller.dart';
import 'package:myday_app/controllers/diary_controller.dart';
import 'package:myday_app/controllers/message_controller.dart';
import 'package:myday_app/controllers/project_controller.dart';
import 'package:myday_app/models/enums.dart';
import 'package:myday_app/services/data_service.dart';
import 'package:myday_app/services/location_service.dart';
import 'package:myday_app/services/verification_service.dart';
import 'package:myday_app/utils/app_exception.dart';
import 'package:myday_app/utils/app_images.dart';
import 'package:myday_app/utils/validators.dart';

const _email = 'rodrigo@iade.pt';
const _password = 'myday2026';

AuthController _newAuth() => AuthController(DataService(), VerificationService());

void main() {
  group('Validators', () {
    test('rejeita email sem domínio completo', () {
      expect(Validators.email('ana.lopes@iade'), isNotNull);
      expect(Validators.email('ana.lopes@iade.pt'), isNull);
    });

    test('valida telemóvel e código', () {
      expect(Validators.phone('912 345 678'), isNull);
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.verificationCode('123456'), isNull);
      expect(Validators.verificationCode('12a456'), isNotNull);
    });
  });

  group('Login com 2 fatores', () {
    test('só inicia sessão depois do código', () {
      final auth = _newAuth();

      auth.startLogin(_email, _password);
      expect(auth.currentUser, isNull);

      auth.confirmCode(auth.pendingVerification!.demoCode);
      expect(auth.currentUser?.firstName, 'Rodrigo');
    });

    test('bloqueia a conta à 3.ª palavra-passe errada', () {
      final auth = _newAuth();

      for (var attempt = 1; attempt <= 2; attempt++) {
        expect(
          () => auth.startLogin(_email, 'errada'),
          throwsA(isA<AppException>().having((e) => e.title, 'title', 'Não foi possível entrar')),
        );
      }
      expect(
        () => auth.startLogin(_email, 'errada'),
        throwsA(isA<AppException>().having((e) => e.title, 'title', 'Conta bloqueada')),
      );
      // Mesmo com a palavra-passe certa continua bloqueada.
      expect(() => auth.startLogin(_email, _password), throwsA(isA<AppException>()));
    });

    test('recuperar a palavra-passe desbloqueia a conta', () {
      final auth = _newAuth();
      for (var attempt = 0; attempt < AuthController.maxLoginAttempts; attempt++) {
        expect(() => auth.startLogin(_email, 'errada'), throwsA(isA<AppException>()));
      }

      auth.requestPasswordReset(_email);
      auth.resetPassword(auth.pendingVerification!.demoCode, 'nova2026');

      auth.startLogin(_email, 'nova2026');
      expect(auth.pendingVerification?.purpose, VerificationPurpose.login);
    });
  });

  group('Convidado e administrador', () {
    test('o convidado entra sem conta e sem código', () {
      final auth = _newAuth();

      auth.continueAsGuest();

      expect(auth.isGuest, isTrue);
      expect(auth.pendingVerification, isNull);
    });

    test('o administrador desbloqueia uma conta bloqueada', () {
      final auth = _newAuth();
      for (var attempt = 0; attempt < AuthController.maxLoginAttempts; attempt++) {
        expect(() => auth.startLogin(_email, 'errada'), throwsA(isA<AppException>()));
      }

      auth.startLogin('admin@iade.pt', 'admin2026');
      auth.confirmCode(auth.pendingVerification!.demoCode);
      final rodrigo = auth.managedUsers.firstWhere((user) => user.email == _email);
      expect(auth.isLocked(rodrigo), isTrue);

      auth.unlockUser(rodrigo);
      expect(auth.isLocked(rodrigo), isFalse);
    });

    test('um estudante não pode desbloquear contas', () {
      final auth = _newAuth();
      auth.startLogin(_email, _password);
      auth.confirmCode(auth.pendingVerification!.demoCode);

      expect(() => auth.unlockUser(auth.managedUsers.first), throwsA(isA<AppException>()));
    });
  });

  group('Registo', () {
    test('a conta só é criada depois de confirmar o código', () {
      final dataService = DataService();
      final auth = AuthController(dataService, VerificationService());

      auth.startRegistration(
        name: 'Marta Silva',
        email: 'marta@iade.pt',
        phone: '914 000 111',
        password: 'segredo123',
        course: 'Design · IADE',
        channel: VerificationChannel.sms,
      );
      expect(dataService.emailExists('marta@iade.pt'), isFalse);

      expect(() => auth.confirmCode('000000'), throwsA(isA<AppException>()));
      auth.confirmCode(auth.pendingVerification!.demoCode);
      expect(dataService.emailExists('marta@iade.pt'), isTrue);
    });

    test('não cria duas contas com o mesmo email', () {
      expect(
        () => _newAuth().startRegistration(
          name: 'Outro',
          email: _email,
          phone: '914000111',
          password: 'segredo123',
          course: 'Design · IADE',
          channel: VerificationChannel.email,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('DiaryController', () {
    test('um novo registo sem fotografia usa a imagem da disciplina', () {
      final diary = DiaryController(DataService(), LocationService());
      final before = diary.todayEntries.length;

      final entry = diary.addEntry(
        title: 'Joins em SQL',
        text: 'Junções no WHERE.',
        subject: Subject.databases,
        project: 'Bases de Dados',
        visibility: EntryVisibility.private,
        tags: const ['sql'],
      );

      expect(diary.todayEntries.length, before + 1);
      expect(entry.imagePath, AppImages.databases);
    });
  });

  group('Dias seguidos', () {
    test('os dados de exemplo têm 12 dias seguidos e a próxima recompensa é aos 14', () {
      final diary = DiaryController(DataService(), LocationService());

      expect(diary.currentStreak, 12);
      expect(diary.bestStreak, 12);
      expect(diary.nextReward?.days, 14);
    });

    test('os registos de um projeto são filtrados pelo nome', () {
      final diary = DiaryController(DataService(), LocationService());

      final entries = diary.entriesForProject('Cálculo I');

      expect(entries, isNotEmpty);
      expect(entries.every((entry) => entry.project == 'Cálculo I'), isTrue);
      expect(diary.projectNamed('Cálculo I'), isNotNull);
    });
  });

  group('Mensagens', () {
    MessageController loggedInAs(String email, String password) {
      final dataService = DataService();
      final auth = AuthController(dataService, VerificationService());
      auth.startLogin(email, password);
      auth.confirmCode(auth.pendingVerification!.demoCode);
      return MessageController(dataService, auth);
    }

    test('mostra as conversas do utilizador, a mais recente primeiro', () {
      final messages = loggedInAs(_email, _password);

      final conversations = messages.conversations;

      expect(conversations.first.contact.firstName, 'Ana');
      expect(conversations.first.unread, 1);
      expect(messages.unreadCount, 1);
    });

    test('abrir a conversa marca as mensagens como lidas', () {
      final messages = loggedInAs(_email, _password);
      final ana = messages.conversations.first.contact;

      messages.markAsRead(ana);

      expect(messages.unreadCount, 0);
    });

    test('enviar uma mensagem acrescenta-a à conversa', () {
      final messages = loggedInAs(_email, _password);
      final ana = messages.conversations.first.contact;
      final before = messages.messagesWith(ana).length;

      messages.send(ana, '  Claro, já partilhei!  ');

      final conversation = messages.messagesWith(ana);
      expect(conversation.length, before + 1);
      expect(conversation.last.text, 'Claro, já partilhei!');
    });

    test('não envia mensagens vazias', () {
      final messages = loggedInAs(_email, _password);
      final ana = messages.conversations.first.contact;
      final before = messages.messagesWith(ana).length;

      messages.send(ana, '   ');

      expect(messages.messagesWith(ana).length, before);
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
