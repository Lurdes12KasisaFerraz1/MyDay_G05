import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_exception.dart';

/// Mostra uma mensagem curta no fundo do ecrã.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Usado nos botões cujo ecrã ainda não existe nesta versão.
void showNotAvailable(BuildContext context, String feature) {
  showMessage(context, '$feature estará disponível numa próxima versão.');
}

/// Popup para erros e avisos importantes.
Future<void> showAlert(
  BuildContext context, {
  required String title,
  required String message,
  bool isError = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
        color: isError ? AppColors.errorBorder : AppColors.success,
        size: 36,
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.link)),
        ),
      ],
    ),
  );
}

Future<void> showErrorAlert(BuildContext context, AppException error) {
  return showAlert(context, title: error.title, message: error.message);
}

/// Mostrado quando um formulário tem campos em falta ou inválidos.
Future<void> showInvalidFormAlert(BuildContext context) {
  return showAlert(
    context,
    title: 'Campos por preencher',
    message: 'Corrige os campos assinalados a vermelho para continuar.',
  );
}
