import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/app_routes.dart';
import '../../utils/messages.dart';
import '../../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/gradient_button.dart';

/// Confirmação por código: usada no registo e no segundo fator do login.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    try {
      widget.authController.confirmCode(_codeController.text);
    } on AppException catch (error) {
      _codeController.clear();
      await showErrorAlert(context, error);
      // Sem pedido pendente (conta bloqueada ou prazo esgotado) não há nada a confirmar.
      if (mounted && widget.authController.pendingVerification == null) {
        Navigator.pop(context);
      }
      return;
    }
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  void _resend(VerificationChannel channel) {
    widget.authController.resendCode(channel);
    _codeController.clear();
    showMessage(context, 'Enviámos um novo código por ${channel.label}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: widget.authController,
            builder: (context, _) {
              final pending = widget.authController.pendingVerification;
              if (pending == null) return const SizedBox.shrink();

              final isSignup = pending.purpose == VerificationPurpose.signup;
              final otherChannel = pending.channel == VerificationChannel.email
                  ? VerificationChannel.sms
                  : VerificationChannel.email;

              return Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    AuthHeader(
                      icon: isSignup ? Icons.mark_email_read_outlined : Icons.verified_user_outlined,
                      title: isSignup ? 'Confirma o teu registo' : 'Verificação em 2 passos',
                      subtitle: 'Enviámos um código de 6 dígitos por ${pending.channel.label} '
                          'para ${pending.destination}. É válido durante 10 minutos.',
                    ),
                    const SizedBox(height: 24),
                    DemoCodeNotice(code: pending.demoCode),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Código',
                      hint: '000000',
                      icon: Icons.pin_outlined,
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      isRequired: true,
                      validator: Validators.verificationCode,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      label: isSignup ? 'Criar conta' : 'Entrar',
                      showArrow: true,
                      onPressed: _confirm,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => _resend(pending.channel),
                          child: const Text(
                            'Reenviar código',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.link),
                          ),
                        ),
                        const Text('·', style: TextStyle(color: AppColors.textSubtle)),
                        TextButton(
                          onPressed: () => _resend(otherChannel),
                          child: Text(
                            'Enviar por ${otherChannel.label}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.link),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
