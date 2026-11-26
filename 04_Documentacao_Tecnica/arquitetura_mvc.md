# Arquitetura da app MyDay

A app segue o padrão MVC. Cada camada tem uma responsabilidade e só conhece a camada abaixo.

## Model – `lib/models`

Classes simples que descrevem os dados, sem lógica de ecrã.

- `User` – nome, email, curso, avatar e contadores (registos, seguidores, dias seguidos).
- `Entry` – um registo do diário: título, texto, disciplina, projeto, visibilidade, local, tags, anexo e comentários.
- `Comment`, `Project`, `StudyGroup`, `Post`.
- `enums.dart` – `Subject`, `EntryVisibility`, `AttachmentType` e `CommunityFeed`, cada um com a etiqueta que aparece na interface.

## Serviço – `lib/services/data_service.dart`

Guarda os dados de exemplo em memória. É o único sítio que os controladores usam para ler e escrever. Quando a app tiver backend, basta substituir esta classe.

## Controller – `lib/controllers`

Cada controlador estende `ChangeNotifier` e chama `notifyListeners()` quando o estado muda.

| Controlador | Responsabilidade |
| --- | --- |
| `AuthController` | entrar, criar conta, terminar sessão e utilizador atual |
| `DiaryController` | registos de hoje e de ontem, estatísticas da semana, criar registo, favoritos e comentários |
| `ProjectController` | lista de projetos, filtro por visibilidade e grupos de estudo |
| `CommunityController` | feed escolhido, pesquisa, favoritos e desafio da semana |
| `SettingsController` | permissões de localização e microfone, lembretes |

As operações que podem falhar (login e registo) devolvem uma mensagem de erro, ou `null` se correrem bem. Assim o ecrã decide como a mostrar.

## View – `lib/views`

- `screens/` – um ficheiro por ecrã. Os ecrãs recebem os controladores no construtor e redesenham-se com `ListenableBuilder`.
- `widgets/` – componentes partilhados (botão em gradiente, cartões, chips, barra de navegação…).

As cores, o tema e o tipo de letra estão centralizados em `lib/utils/app_colors.dart` e `lib/utils/app_theme.dart`.

## Navegação

As rotas estão em `lib/utils/app_routes.dart` e são resolvidas em `app.dart` (`onGenerateRoute`).

```
Abertura ──► Boas-vindas ──► Criar conta ◄──► Entrar
                                   │              │
                                   └──────┬───────┘
                                          ▼
                    MainScreen (barra inferior)
          Diário │ Projetos │ Comunidade │ Perfil
             │                   │           │
             ├─ + ─► Novo registo ◄─ Participar
             │            │
             └──► Detalhe do registo ──► Projetos
                                           Perfil ──► Terminar sessão ► Boas-vindas
```

- A `MainScreen` usa um `IndexedStack`, por isso cada separador mantém o seu estado (scroll, filtros) ao trocar.
- O botão `+` só aparece no separador Diário.
- Depois de guardar, o novo registo abre logo no ecrã de detalhe.
- Os botões de funcionalidades que ainda não existem (mapa, notificações, exportar PDF…) mostram uma mensagem a avisar que ficam para uma próxima versão.
