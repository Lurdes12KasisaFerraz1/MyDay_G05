import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

/// Devolve true se o utilizador tem conta. Se for convidado, explica que a
/// ação precisa de conta e oferece-se para a criar.
Future<bool> ensureAccount(BuildContext context, AuthController authController, String action) async {
  if (!authController.isGuest) return true;

  final wantsAccount = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.link, size: 36),
      title: const Text('Cria uma conta', textAlign: TextAlign.center),
      content: Text(
        'Como convidado podes explorar a app, mas para $action precisas de uma conta.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Agora não', style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.link)),
        ),
      ],
    ),
  );

  if (wantsAccount == true && context.mounted) {
    Navigator.pushNamed(context, AppRoutes.signup);
  }
  return false;
}
