import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/community_controller.dart';
import '../../controllers/diary_controller.dart';
import '../../controllers/project_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/bottom_nav_bar.dart';
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
    required this.settingsController,
  });

  final int initialTab;
  final AuthController authController;
  final DiaryController diaryController;
  final ProjectController projectController;
  final CommunityController communityController;
  final SettingsController settingsController;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _diaryTab = 0;

  late int _currentTab = widget.initialTab;

  void _openNewEntry() => Navigator.pushNamed(context, AppRoutes.newEntry);

  @override
  Widget build(BuildContext context) {
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
              ProjectsScreen(projectController: widget.projectController),
              CommunityScreen(communityController: widget.communityController),
              ProfileScreen(
                authController: widget.authController,
                settingsController: widget.settingsController,
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
