import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'controllers/community_controller.dart';
import 'controllers/diary_controller.dart';
import 'controllers/message_controller.dart';
import 'controllers/project_controller.dart';
import 'controllers/settings_controller.dart';
import 'models/entry.dart';
import 'models/project.dart';
import 'models/study_group.dart';
import 'models/user.dart';
import 'services/data_service.dart';
import 'services/location_service.dart';
import 'services/verification_service.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'views/screens/calendar_screen.dart';
import 'views/screens/chat_screen.dart';
import 'views/screens/entry_detail_screen.dart';
import 'views/screens/forgot_password_screen.dart';
import 'views/screens/group_detail_screen.dart';
import 'views/screens/groups_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/main_screen.dart';
import 'views/screens/map_screen.dart';
import 'views/screens/messages_screen.dart';
import 'views/screens/new_entry_screen.dart';
import 'views/screens/project_detail_screen.dart';
import 'views/screens/signup_screen.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/verify_code_screen.dart';
import 'views/screens/welcome_screen.dart';

class MyDayApp extends StatefulWidget {
  const MyDayApp({super.key});

  @override
  State<MyDayApp> createState() => _MyDayAppState();
}

class _MyDayAppState extends State<MyDayApp> {
  final DataService _dataService = DataService();

  late final AuthController _authController = AuthController(_dataService, VerificationService());
  late final DiaryController _diaryController = DiaryController(_dataService, LocationService());
  late final ProjectController _projectController = ProjectController(_dataService);
  late final CommunityController _communityController = CommunityController(_dataService);
  late final MessageController _messageController = MessageController(_dataService, _authController);
  final SettingsController _settingsController = SettingsController();

  @override
  void dispose() {
    _authController.dispose();
    _diaryController.dispose();
    _projectController.dispose();
    _communityController.dispose();
    _messageController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.welcome => WelcomeScreen(authController: _authController),
      AppRoutes.login => LoginScreen(authController: _authController),
      AppRoutes.signup => SignupScreen(authController: _authController),
      AppRoutes.verifyCode => VerifyCodeScreen(authController: _authController),
      AppRoutes.forgotPassword => ForgotPasswordScreen(authController: _authController),
      AppRoutes.home => MainScreen(
          initialTab: settings.arguments as int? ?? 0,
          authController: _authController,
          diaryController: _diaryController,
          projectController: _projectController,
          communityController: _communityController,
          messageController: _messageController,
          settingsController: _settingsController,
        ),
      AppRoutes.newEntry => NewEntryScreen(
          diaryController: _diaryController,
          settingsController: _settingsController,
          initialProject: settings.arguments as String?,
        ),
      AppRoutes.projectDetail => ProjectDetailScreen(
          project: settings.arguments! as Project,
          diaryController: _diaryController,
          authController: _authController,
        ),
      AppRoutes.map => MapScreen(
          diaryController: _diaryController,
          focusEntry: settings.arguments as Entry?,
        ),
      AppRoutes.calendar => CalendarScreen(diaryController: _diaryController),
      AppRoutes.groups => GroupsScreen(projectController: _projectController, authController: _authController),
      AppRoutes.groupDetail => GroupDetailScreen(
          group: settings.arguments! as StudyGroup,
          projectController: _projectController,
          authController: _authController,
        ),
      AppRoutes.messages => MessagesScreen(messageController: _messageController),
      AppRoutes.chat => ChatScreen(
          contact: settings.arguments! as User,
          messageController: _messageController,
        ),
      AppRoutes.entryDetail => EntryDetailScreen(
          entry: settings.arguments! as Entry,
          diaryController: _diaryController,
          authController: _authController,
        ),
      _ => const SplashScreen(),
    };

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
