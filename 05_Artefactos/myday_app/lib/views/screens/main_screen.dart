import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/community_controller.dart';
import '../../controllers/diary_controller.dart';
import '../../controllers/message_controller.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/guest_prompt.dart';
import 'community_screen.dart';
import 'diary_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';

/// Ecrã principal com a barra de navegação e os quatro separadores.
class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.initialTab,
    required this.authController,
    required this.diaryController,
    required this.projectController,
    required this.communityController,
    required this.messageController,
    required this.settingsController,
  });

  final int initialTab;
  final AuthController authController;
  final DiaryController diaryController;
  final ProjectController projectController;
  final CommunityController communityController;
  final MessageController messageController;
  final SettingsController settingsController;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _diaryTab = 0;

  late int _currentTab = widget.initialTab;

  Future<void> _openNewEntry() async {
    final hasAccount = await ensureAccount(context, widget.authController, 'guardar registos');
    if (!hasAccount || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.newEntry);
  }

  Future<void> _openMessages() async {
    final hasAccount = await ensureAccount(context, widget.authController, 'enviar mensagens');
    if (!hasAccount || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.messages);
  }

  void _backToDiary() => setState(() => _currentTab = _diaryTab);

  @override
  Widget build(BuildContext context) {
    // O botão "voltar" do sistema regressa primeiro ao Diário antes de sair.
    return PopScope(
      canPop: _currentTab == _diaryTab,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToDiary();
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentTab,
            children: [
              DiaryScreen(
                diaryController: widget.diaryController,
                authController: widget.authController,
              ),
              ProjectsScreen(projectController: widget.projectController, onBack: _backToDiary),
              CommunityScreen(
                communityController: widget.communityController,
                onBack: _backToDiary,
                onParticipate: _openNewEntry,
                messageController: widget.messageController,
                onOpenMessages: _openMessages,
              ),
              ProfileScreen(
                authController: widget.authController,
                diaryController: widget.diaryController,
                settingsController: widget.settingsController,
                onBack: _backToDiary,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        onCreateEntry: _currentTab == _diaryTab ? _openNewEntry : null,
      ),
    );
  }
}
