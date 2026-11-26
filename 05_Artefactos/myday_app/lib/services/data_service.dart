import '../models/comment.dart';
import '../models/entry.dart';
import '../models/enums.dart';
import '../models/message.dart';
import '../models/post.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../utils/app_images.dart';

/// Fonte de dados da aplicação.
///
/// Nesta versão os dados ficam guardados em memória. Quando existir o
/// backend em Node.js, só esta classe precisa de passar a fazer pedidos HTTP;
/// os controladores e os ecrãs mantêm-se iguais.
class DataService {
  DataService() {
    _loadSampleData();
  }

  final List<User> _users = [];
  final List<Entry> _entries = [];
  final List<Project> _projects = [];
  final List<StudyGroup> _groups = [];
  final List<Post> _posts = [];
  final List<Message> _messages = [];

  List<User> get users => List.unmodifiable(_users);
  List<Entry> get entries => List.unmodifiable(_entries);
  List<Project> get projects => List.unmodifiable(_projects);
  List<StudyGroup> get groups => List.unmodifiable(_groups);
  List<Post> get posts => List.unmodifiable(_posts);
  List<Message> get messages => List.unmodifiable(_messages);

  String get weeklyChallenge => 'Explica um conceito em 60 segundos de vídeo';

  User? findUserByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email == normalized) return user;
    }
    return null;
  }

  bool emailExists(String email) {
    return _users.any((user) => user.email == email.trim().toLowerCase());
  }

  void addUser(User user) => _users.add(user);

  void addEntry(Entry entry) => _entries.insert(0, entry);

  void addMessage(Message message) => _messages.add(message);

  String nextMessageId() => 'm${_messages.length + 1}';

  String nextEntryId() => 'e${_entries.length + 1}';

  void _loadSampleData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    _users.addAll([
      User(
        name: 'Rodrigo Rodrigues',
        email: 'rodrigo@iade.pt',
        password: 'myday2026',
        phone: '912345678',
        course: 'Eng. Informática · IADE',
        avatarPath: AppImages.avatarRodrigo,
        entriesCount: 86,
        followers: 41,
        following: 38,
      ),
      User(
        name: 'Ana Lopes',
        email: 'ana.lopes@iade.pt',
        password: 'myday2026',
        phone: '913456789',
        course: 'Eng. Informática · IADE',
        avatarPath: AppImages.avatarAna,
        entriesCount: 86,
        followers: 41,
        following: 38,
      ),
      User(
        name: 'Admin MyDay',
        email: 'admin@iade.pt',
        password: 'admin2026',
        phone: '910000000',
        course: 'Administração · IADE',
        avatarPath: AppImages.logoIcon,
        role: UserRole.admin,
      ),
      User(
        name: 'Inês Martins',
        email: 'ines.martins@iade.pt',
        password: 'myday2026',
        phone: '914222333',
        course: 'Design · IADE',
        avatarPath: AppImages.avatarInes,
      ),
      User(
        name: 'Tiago Fonseca',
        email: 'tiago.fonseca@iade.pt',
        password: 'myday2026',
        phone: '915444555',
        course: 'Eng. Informática · IADE',
        avatarPath: AppImages.avatarTiago,
      ),
    ]);
    _messages.addAll(_sampleMessages(now));

    _entries.addAll([
      Entry(
        id: 'e1',
        title: 'Derivadas: regra da cadeia',
        text: 'Finalmente percebi porque se multiplica pela derivada interior. '
            'O exercício 4 da ficha ajudou muito.',
        subject: Subject.mathematics,
        project: 'Cálculo I',
        createdAt: today.add(const Duration(hours: 10, minutes: 42)),
        location: 'Biblioteca IADE',
        latitude: 38.70755,
        longitude: -9.15290,
        imagePath: AppImages.derivatives,
        tags: const ['derivadas', 'cálculo'],
        comments: [
          Comment(
            authorName: 'Tiago Reis',
            authorAvatar: AppImages.avatarTiago,
            text: 'O exercício 4 também me salvou. Tens a resolução do 5?',
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      Entry(
        id: 'e2',
        title: 'Normalização até à 3FN',
        text: 'Dividi a tabela de inscrições em três. Gravei a explicação.',
        subject: Subject.databases,
        project: 'Bases de Dados',
        createdAt: today.add(const Duration(hours: 9, minutes: 15)),
        visibility: EntryVisibility.friends,
        location: 'IADE · Sala 2.04',
        latitude: 38.70712,
        longitude: -9.15234,
        imagePath: AppImages.databases,
        mediaType: AttachmentType.audio,
        mediaLabel: 'Áudio · 1:24',
      ),
      Entry(
        id: 'e3',
        title: 'Primeiro ecrã em Flutter',
        text: 'Montei o ecrã inicial da app com a barra de navegação.',
        subject: Subject.mobile,
        project: 'App MyDay',
        createdAt: yesterday.add(const Duration(hours: 18, minutes: 30)),
        location: 'Casa · Alcântara',
        latitude: 38.70389,
        longitude: -9.17602,
        imagePath: AppImages.mobileApp,
        mediaType: AttachmentType.video,
        mediaLabel: 'Vídeo · 0:42',
      ),
    ]);

    _entries.addAll(_pastEntries(today));

    _projects.addAll(const [
      Project(
        name: 'Cálculo I',
        coverImage: AppImages.derivatives,
        visibility: EntryVisibility.private,
        entriesCount: 14,
        lastActivity: 'hoje',
        description: 'Limites, derivadas e integrais: o que percebi em cada aula e as fichas resolvidas.',
      ),
      Project(
        name: 'App MyDay',
        coverImage: AppImages.developer,
        visibility: EntryVisibility.public,
        entriesCount: 23,
        lastActivity: 'ontem',
        description: 'Diário do desenvolvimento da app MyDay em Flutter, ecrã a ecrã.',
      ),
      Project(
        name: 'Química – laboratório',
        coverImage: AppImages.chemistryLab,
        visibility: EntryVisibility.friends,
        entriesCount: 6,
        lastActivity: 'há 3 dias',
        description: 'Registos das aulas práticas: montagens, observações e resultados.',
      ),
      Project(
        name: 'Bases de Dados',
        coverImage: AppImages.databases,
        visibility: EntryVisibility.friends,
        entriesCount: 11,
        lastActivity: 'há 5 dias',
        description: 'Modelação ER, normalização e SQL para o teste e para o projeto de grupo.',
      ),
    ]);

    _groups.add(
      const StudyGroup(
        name: 'Grupo BD 2026',
        memberAvatars: [AppImages.avatarTiago, AppImages.avatarInes],
        membersCount: 5,
        sharedEntries: 12,
      ),
    );

    _posts.addAll([
      Post(
        authorName: 'Inês Martins',
        authorAvatar: AppImages.avatarInes,
        project: 'Química – laboratório',
        timeAgo: '2 h',
        title: 'Titulação ácido-base',
        text: 'Registei a mudança de cor no ponto de equivalência.',
        imagePath: AppImages.chemistryLab,
        visibility: EntryVisibility.friends,
        commentsCount: 4,
        feed: CommunityFeed.following,
      ),
      Post(
        authorName: 'Tiago Reis',
        authorAvatar: AppImages.avatarTiago,
        project: 'Algoritmos',
        timeAgo: '5 h',
        title: 'Grafos: Dijkstra à mão',
        text: 'Fiz o exemplo das aulas passo a passo no caderno.',
        imagePath: AppImages.classroom,
        visibility: EntryVisibility.public,
        commentsCount: 7,
        feed: CommunityFeed.discover,
      ),
      Post(
        authorName: 'Grupo BD 2026',
        authorAvatar: AppImages.avatarTiago,
        project: 'Bases de Dados',
        timeAgo: 'ontem',
        title: 'Resumo para o teste',
        text: 'Juntámos os exercícios de normalização num só documento.',
        imagePath: AppImages.databases,
        visibility: EntryVisibility.friends,
        commentsCount: 2,
        feed: CommunityFeed.groups,
      ),
    ]);
  }

  /// Um registo por dia nos últimos 10 dias, para o calendário mostrar uma
  /// sequência de dias seguidos.
  List<Entry> _pastEntries(DateTime today) {
    const samples = [
      ('Integrais por partes', Subject.mathematics, 'Cálculo I', AppImages.derivatives),
      ('Modelo ER da biblioteca', Subject.databases, 'Bases de Dados', AppImages.databases),
      ('Navegação entre ecrãs', Subject.mobile, 'App MyDay', AppImages.developer),
      ('Titulação: preparação', Subject.chemistry, 'Química – laboratório', AppImages.chemistryLab),
      ('Limites notáveis', Subject.mathematics, 'Cálculo I', AppImages.derivatives),
      ('Chaves estrangeiras', Subject.databases, 'Bases de Dados', AppImages.databases),
      ('Widgets com estado', Subject.mobile, 'App MyDay', AppImages.mobileApp),
      ('Soluções tampão', Subject.chemistry, 'Química – laboratório', AppImages.chemistryLab),
      ('Regra de L\'Hôpital', Subject.mathematics, 'Cálculo I', AppImages.derivatives),
      ('Consultas com GROUP BY', Subject.databases, 'Bases de Dados', AppImages.databases),
    ];

    return [
      for (var i = 0; i < samples.length; i++)
        Entry(
          id: 'p${i + 1}',
          title: samples[i].$1,
          text: 'Resumo da aula e dos exercícios feitos.',
          subject: samples[i].$2,
          project: samples[i].$3,
          createdAt: today.subtract(Duration(days: i + 2)).add(const Duration(hours: 17)),
          location: 'IADE',
          latitude: 38.70735 + i * 0.0004,
          longitude: -9.15265 - i * 0.0005,
          imagePath: samples[i].$4,
        ),
    ];
  }

  List<Message> _sampleMessages(DateTime now) {
    final rodrigo = _users[0];
    final ana = _users[1];
    final ines = _users[3];
    final tiago = _users[4];

    Message message(String id, User from, User to, String text, Duration ago, {bool read = true}) {
      final sentAt = now.subtract(ago);
      return Message(
        id: id,
        sender: from,
        receiver: to,
        text: text,
        sentAt: sentAt,
        readAt: read ? sentAt.add(const Duration(minutes: 2)) : null,
      );
    }

    return [
      message('m1', ana, rodrigo, 'Olá! Já fizeste a ficha de derivadas?', const Duration(hours: 3)),
      message('m2', rodrigo, ana, 'Já! Usei a regra da cadeia em quase todas.', const Duration(hours: 2, minutes: 50)),
      message('m3', ana, rodrigo, 'Podes partilhar o teu registo comigo?', const Duration(minutes: 40), read: false),
      message('m4', tiago, rodrigo, 'Vamos rever SQL amanhã na biblioteca?', const Duration(days: 1, hours: 2)),
      message('m5', rodrigo, tiago, 'Combinado, às 10h.', const Duration(days: 1, hours: 1)),
      message('m6', ines, ana, 'Gostei muito do teu projeto de química!', const Duration(hours: 5)),
    ];
  }
}
