import 'package:flutter/material.dart';

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
