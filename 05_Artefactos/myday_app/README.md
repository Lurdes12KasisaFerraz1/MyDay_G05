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
| Código de confirmação / 2 fatores | `lib/views/screens/verify_code_screen.dart` |
| Recuperar palavra-passe | `lib/views/screens/forgot_password_screen.dart` |
| Detalhe do projeto | `lib/views/screens/project_detail_screen.dart` |
| Mapa | `lib/views/screens/map_screen.dart` |
| Calendário e recompensas | `lib/views/screens/calendar_screen.dart` |
| Grupos de estudo e detalhe do grupo | `lib/views/screens/groups_screen.dart`, `group_detail_screen.dart` |
| Mensagens (lista de conversas) | `lib/views/screens/messages_screen.dart` |
| Chat | `lib/views/screens/chat_screen.dart` |
| Projetos | `lib/views/screens/projects_screen.dart` |
| Comunidade | `lib/views/screens/community_screen.dart` |
| Perfil | `lib/views/screens/profile_screen.dart` |

## Segurança e validação

- **Bloqueio da conta:** à 3.ª palavra-passe (ou código) errada a conta fica bloqueada. Desbloqueia-se ao recuperar a palavra-passe.
- **Confirmação do registo:** a conta só é criada depois de introduzir o código de 6 dígitos enviado por email ou SMS (à escolha).
- **Login com 2 fatores:** depois da palavra-passe é pedido um código enviado por email; pode ser reenviado ou pedido por SMS.
- **Recuperar palavra-passe:** email → código → nova palavra-passe.
- Os códigos têm 6 dígitos, valem 10 minutos e só podem ser usados uma vez.
- Os erros aparecem num popup e os campos obrigatórios (*) em falta ou inválidos ficam a vermelho.

> **Modo demonstração:** ainda não há servidor para enviar emails e SMS, por isso o código aparece num aviso no próprio ecrã. Quando existir backend, basta que o `VerificationService` peça ao servidor para gerar e enviar o código.

## Registos

- **GPS:** o botão *Local* do novo registo vai buscar a posição atual do telemóvel (é preciso a permissão de localização e o interruptor *Localização* ativo no Perfil).
- **Fotografias por categoria:** o botão *Foto* abre as fotografias da app organizadas em Matemática, Bases de Dados, Programação, Química e Estudo. Um registo sem fotografia usa a imagem da disciplina.
- **Detalhe do projeto:** toca num projeto (ou no chip do projeto num registo) para ver a descrição, os números, as disciplinas e os registos, e criar um registo já associado a esse projeto.
- **Mapa:** em Diário → *Mapa*, ou *Ver no mapa* num registo. Mostra os registos com posição GPS sobre o OpenStreetMap; tocar num marcador mostra o registo.
- **Calendário com recompensas:** em Diário → *Calendário*, ou no cartão dos dias seguidos. Mostra o mês com os dias com registo, a sequência atual e a melhor, a barra de progresso até à próxima recompensa e as medalhas (3, 7, 14, 30, 60 e 100 dias seguidos). Tocar num dia mostra os registos desse dia.
- **Grupos de estudo:** em Projetos → *Ver todos* (os meus grupos e outros grupos) ou tocando num grupo. O detalhe mostra a descrição, o dono, os números, o lembrete do grupo (só o dono o liga/desliga) e os membros com o papel *Dono* ou *Membro*; dá para entrar ou sair do grupo e enviar mensagem a qualquer membro.
- **Mensagens:** botão de mensagens na Comunidade (com um ponto azul quando há mensagens por ler). Mostra as conversas da mais recente para a mais antiga, com o número de mensagens por ler; o lápis inicia uma conversa nova. No chat as mensagens ficam agrupadas por dia e a última enviada mostra se já foi *Lida*. O convidado é convidado a criar conta.
- **Código QR do perfil:** o botão pequeno de QR no Perfil mostra o código e permite partilhá-lo (imagem + link) pelas apps do telemóvel.
- Todos os ecrãs secundários têm botão de voltar; nos separadores, o voltar regressa ao Diário.

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

### Permissões de localização (depois do `flutter create .`)

Android – em `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

iOS – em `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>O MyDay usa a localização para guardar onde fizeste cada registo.</string>
```

Verificação e testes:

```bash
flutter analyze
flutter test
```

Contas de demonstração:

| Conta | Email | Palavra-passe |
| --- | --- | --- |
| Estudante | rodrigo@iade.pt | myday2026 |
| Estudante | ana.lopes@iade.pt | myday2026 |
| Administrador | admin@iade.pt | admin2026 |
| Estudante | ines.martins@iade.pt | myday2026 |
| Estudante | tiago.fonseca@iade.pt | myday2026 |

- **Convidado:** em *Explorar como convidado* (Boas-vindas) ou *Continuar como convidado* (Entrar). Pode ver a app, mas para guardar registos, comentar ou favoritar é convidado a criar conta.
- **Administrador:** no Perfil aparece *Gestão de contas*, com a lista de contas e o botão *Desbloquear* para as que foram bloqueadas.

Os dados ficam em memória, por isso voltam ao estado inicial sempre que a app é reiniciada.

## Dependências

- `geolocator` – acesso ao GPS do telemóvel (não existe alternativa no SDK do Flutter).
- `flutter_map` e `latlong2` – mapa com o OpenStreetMap (gratuito, sem chave de API).
- `qr_flutter` – desenha o código QR do perfil.
- `share_plus` e `cross_file` – abrem a folha de partilha do telemóvel com a imagem do QR.
- `flutter_lints` – só em desenvolvimento.

O estado é gerido com `ChangeNotifier` e `ListenableBuilder`, sem pacotes de gestão de estado.

## Créditos

- Tipo de letra Plus Jakarta Sans, licença SIL Open Font License (`assets/fonts/OFL.txt`).
- Fotografias de templates open source com licença MIT (Themefisher, Creative Tim) e fotografias do grupo.
- Ícones: Material Icons, incluídos no Flutter.
