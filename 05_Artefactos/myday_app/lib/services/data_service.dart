import '../models/comment.dart';
import '../models/entry.dart';
import '../models/enums.dart';
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

  List<Entry> get entries => List.unmodifiable(_entries);
  List<Project> get projects => List.unmodifiable(_projects);
  List<StudyGroup> get groups => List.unmodifiable(_groups);
  List<Post> get posts => List.unmodifiable(_posts);

  String get weeklyChallenge => 'Explica um conceito em 60 segundos de vídeo';

  User? findUser(String email, String password) {
    for (final user in _users) {
      if (user.email == email.trim().toLowerCase() && user.password == password) {
        return user;
      }
    }
    return null;
  }

  bool emailExists(String email) {
    return _users.any((user) => user.email == email.trim().toLowerCase());
  }

  void addUser(User user) => _users.add(user);

  void addEntry(Entry entry) => _entries.insert(0, entry);

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
        course: 'Eng. Informática · IADE',
        avatarPath: AppImages.avatarRodrigo,
        entriesCount: 86,
        followers: 41,
        following: 38,
        streakDays: 12,
      ),
      User(
        name: 'Ana Lopes',
        email: 'ana.lopes@iade.pt',
        password: 'myday2026',
        course: 'Eng. Informática · IADE',
        avatarPath: AppImages.avatarAna,
        entriesCount: 86,
        followers: 41,
        following: 38,
        streakDays: 7,
      ),
    ]);

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
        imagePath: AppImages.mobileApp,
        mediaType: AttachmentType.video,
        mediaLabel: 'Vídeo · 0:42',
      ),
    ]);

    _projects.addAll(const [
      Project(
        name: 'Cálculo I',
        coverImage: AppImages.derivatives,
        visibility: EntryVisibility.private,
        entriesCount: 14,
        lastActivity: 'hoje',
      ),
      Project(
        name: 'App MyDay',
        coverImage: AppImages.developer,
        visibility: EntryVisibility.public,
        entriesCount: 23,
        lastActivity: 'ontem',
      ),
      Project(
        name: 'Química – laboratório',
        coverImage: AppImages.chemistryLab,
        visibility: EntryVisibility.friends,
        entriesCount: 6,
        lastActivity: 'há 3 dias',
      ),
      Project(
        name: 'Bases de Dados',
        coverImage: AppImages.databases,
        visibility: EntryVisibility.friends,
        entriesCount: 11,
        lastActivity: 'há 5 dias',
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
}
