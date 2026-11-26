import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/app_routes.dart';
import '../../utils/messages.dart';
import '../widgets/gradient_button.dart';
import '../widgets/profile_qr_sheet.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.authController,
    required this.settingsController,
    required this.onBack,
  });

  final AuthController authController;
  final SettingsController settingsController;
  final VoidCallback onBack;

  void _logout(BuildContext context) {
    authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Apagar conta?'),
        content: const Text('Os teus registos e projetos deixam de estar disponíveis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Apagar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;
    if (user == null) return const SizedBox.shrink();
    if (user.isGuest) return _GuestProfile(onBack: onBack, onLeave: () => _logout(context));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar ao Diário', onPressed: onBack),
        ),
        const SizedBox(height: 12),
        _ProfileHeader(user: user),
        const SizedBox(height: 16),
        _StatsCard(user: user),
        if (user.isAdmin) ...[
          const SizedBox(height: 22),
          const SectionHeader(title: 'Gestão de contas'),
          const SizedBox(height: 12),
          _AdminPanel(authController: authController),
        ],
        const SizedBox(height: 22),
        const SectionHeader(title: 'Conquistas'),
        const SizedBox(height: 12),
        _Achievements(streakDays: user.streakDays),
        const SizedBox(height: 22),
        const SectionHeader(title: 'Privacidade e permissões'),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: settingsController,
          builder: (context, _) => _SettingsCard(
            settings: settingsController,
            onExport: () => showNotAvailable(context, 'A exportação de dados'),
            onDeleteAccount: () => _confirmDeleteAccount(context),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => _logout(context),
            child: const Text(
              'Terminar sessão',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: CircleAvatar(radius: 31, backgroundImage: AssetImage(user.avatarPath)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(user.course, style: Theme.of(context).textTheme.bodySmall),
              if (user.isAdmin) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    user.role.label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3D2800)),
                  ),
                ),
              ],
            ],
          ),
        ),
        RoundIconButton(
          icon: Icons.qr_code_2_rounded,
          tooltip: 'Partilhar código QR',
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            backgroundColor: AppColors.surface,
            builder: (_) => ProfileQrSheet(user: user),
          ),
        ),
      ],
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.onBack, required this.onLeave});

  final VoidCallback onBack;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar ao Diário', onPressed: onBack),
        ),
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.glass,
          child: Icon(Icons.person_outline_rounded, size: 40, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Text('Modo convidado', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'Podes ver a comunidade e os projetos. Para guardar registos, comentar e ter perfil, cria uma conta.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.45, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Criar conta',
          showArrow: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: onLeave,
            child: const Text(
              'Sair do modo convidado',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lista das contas, visível só para o administrador, com opção de desbloquear.
class _AdminPanel extends StatelessWidget {
  const _AdminPanel({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            for (final user in authController.managedUsers)
              ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage(user.avatarPath)),
                title: Text(
                  user.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                subtitle: Text(
                  authController.isLocked(user) ? '${user.email} · bloqueada' : user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: authController.isLocked(user) ? AppColors.error : AppColors.textMuted,
                  ),
                ),
                trailing: authController.isLocked(user)
                    ? TextButton(
                        onPressed: () => _unlock(context, user),
                        child: const Text(
                          'Desbloquear',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.link),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
              ),
          ],
        ),
      ),
    );
  }

  void _unlock(BuildContext context, User user) {
    try {
      authController.unlockUser(user);
      showMessage(context, 'A conta de ${user.firstName} foi desbloqueada.');
    } on AppException catch (error) {
      showErrorAlert(context, error);
    }
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Stat(value: user.entriesCount, label: 'Registos'),
            const VerticalDivider(color: AppColors.surfaceBorder, width: 1),
            _Stat(value: user.followers, label: 'Seguidores'),
            const VerticalDivider(color: AppColors.surfaceBorder, width: 1),
            _Stat(value: user.following, label: 'A seguir'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  const _Achievements({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Achievement(
          icon: Icons.local_fire_department_rounded,
          label: '7 dias seguidos',
          color: AppColors.gold,
          unlocked: streakDays >= 7,
        ),
        const SizedBox(width: 10),
        const _Achievement(
          icon: Icons.public_rounded,
          label: '1.º projeto público',
          color: AppColors.link,
          unlocked: true,
        ),
        const SizedBox(width: 10),
        _Achievement(
          icon: Icons.emoji_events_outlined,
          label: '30 dias seguidos',
          color: AppColors.gold,
          unlocked: streakDays >= 30,
        ),
      ],
    );
  }
}

class _Achievement extends StatelessWidget {
  const _Achievement({
    required this.icon,
    required this.label,
    required this.color,
    required this.unlocked,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: unlocked ? color.withAlpha(41) : AppColors.glass,
              child: Icon(unlocked ? icon : Icons.lock_outline_rounded, color: unlocked ? color : AppColors.textSubtle),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: unlocked ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.settings,
    required this.onExport,
    required this.onDeleteAccount,
  });

  final SettingsController settings;
  final VoidCallback onExport;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SettingSwitch(
            title: 'Localização',
            subtitle: 'Só quando adicionas a um registo',
            value: settings.locationEnabled,
            onChanged: settings.setLocation,
          ),
          _SettingSwitch(
            title: 'Microfone',
            subtitle: 'Para gravar áudio',
            value: settings.microphoneEnabled,
            onChanged: settings.setMicrophone,
          ),
          _SettingSwitch(
            title: 'Lembretes diários',
            subtitle: 'Todos os dias às 21:00',
            value: settings.remindersEnabled,
            onChanged: settings.setReminders,
          ),
          ListTile(
            title: const Text(
              'Exportar os meus dados',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            trailing: const Icon(Icons.download_rounded, color: AppColors.textMuted),
            onTap: onExport,
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          ListTile(
            title: const Text(
              'Apagar conta',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error),
            ),
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: onChanged,
        ),
        const Divider(height: 1, color: AppColors.surfaceBorder),
      ],
    );
  }
}
