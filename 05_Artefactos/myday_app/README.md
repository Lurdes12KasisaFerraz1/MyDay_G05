# MyDay – app

Aplicação móvel em Flutter do projeto MyDay (Grupo G05, IADE). É um diário de aprendizagem: o estudante regista o que aprendeu, organiza os registos por disciplina e projeto e partilha-os, se quiser, com a comunidade.

## Ecrãs

| Ecrã | Ficheiro |
| --- | --- |
| Abertura | `lib/views/screens/splash_screen.dart` |
| Boas-vindas | `lib/views/screens/welcome_screen.dart` |
| Entrar | `lib/views/screens/login_screen.dart` |
| Criar conta | `lib/views/screens/signup_screen.dart` |
| Diário | `lib/views/screens/diary_screen.dart` |
| Novo registo | `lib/views/screens/new_entry_screen.dart` |
| Detalhe do registo | `lib/views/screens/entry_detail_screen.dart` |
| Projetos | `lib/views/screens/projects_screen.dart` |
| Comunidade | `lib/views/screens/community_screen.dart` |
| Perfil | `lib/views/screens/profile_screen.dart` |

## Estrutura (MVC)

```
lib/
├── main.dart, app.dart   arranque, controladores e rotas
├── models/               dados (User, Entry, Project, Post, …)
├── services/             DataService – dados de exemplo em memória
├── controllers/          lógica e estado (ChangeNotifier)
├── views/
│   ├── screens/          um ficheiro por ecrã
│   └── widgets/          componentes reutilizados
└── utils/                cores, tema, rotas, validações, datas
```

A explicação completa está em `04_Documentacao_Tecnica/arquitetura_mvc.md`.

## Como correr

É preciso o Flutter 3.24 ou superior.

```bash
cd 05_Artefactos/myday_app
flutter create .        # só na primeira vez: gera as pastas android/ e ios/
flutter pub get
flutter run
```

Verificação e testes:

```bash
flutter analyze
flutter test
```

Contas de demonstração (palavra-passe `myday2026`):

- rodrigo@iade.pt
- ana.lopes@iade.pt

Os dados ficam em memória, por isso voltam ao estado inicial sempre que a app é reiniciada.

## Dependências

Só o SDK do Flutter e o `flutter_lints` (apenas em desenvolvimento). O estado é gerido com `ChangeNotifier` e `ListenableBuilder`, sem pacotes externos.

## Créditos

- Tipo de letra Plus Jakarta Sans, licença SIL Open Font License (`assets/fonts/OFL.txt`).
- Fotografias de templates open source com licença MIT (Themefisher, Creative Tim) e fotografias do grupo.
- Ícones: Material Icons, incluídos no Flutter.
