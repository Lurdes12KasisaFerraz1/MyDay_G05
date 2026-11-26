import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_exception.dart';
import '../../utils/messages.dart';
import '../../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/gradient_button.dart';

/// Recuperação da palavra-passe em dois passos: pedir o código e definir a nova.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_formKey.currentState!.validate()) return true;
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    showInvalidFormAlert(context);
    return false;
  }

  void _sendCode() {
    if (!_validateForm()) return;
    try {
      widget.authController.requestPasswordReset(_emailController.text);
      setState(() {
        _codeSent = true;
        _autovalidate = AutovalidateMode.disabled;
      });
    } on AppException catch (error) {
      showErrorAlert(context, error);
    }
  }

  Future<void> _resetPassword() async {
    if (!_validateForm()) return;
    try {
      widget.authController.resetPassword(_codeController.text, _passwordController.text);
    } on AppException catch (error) {
      _codeController.clear();
      showErrorAlert(context, error);
      return;
    }

    await showAlert(
      context,
      title: 'Palavra-passe alterada',
      message: 'A conta está desbloqueada. Já podes entrar com a nova palavra-passe.',
      isError: false,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.authController.pendingVerification;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                AuthHeader(
                  icon: Icons.lock_reset_rounded,
                  title: 'Recuperar palavra-passe',
                  subtitle: _codeSent && pending != null
                      ? 'Enviámos um código para ${pending.destination}. Escolhe a nova palavra-passe.'
                      : 'Escreve o email da tua conta e enviamos-te um código para criares uma nova.',
                ),
                const SizedBox(height: 24),
                if (!_codeSent) ...[
                  AppTextField(
                    label: 'Email',
                    hint: 'nome@iade.pt',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  GradientButton(label: 'Enviar código', showArrow: true, onPressed: _sendCode),
                ] else ...[
                  if (pending != null) ...[
                    DemoCodeNotice(code: pending.demoCode),
                    const SizedBox(height: 18),
                  ],
                  AppTextField(
                    label: 'Código',
                    hint: '000000',
                    icon: Icons.pin_outlined,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    isRequired: true,
                    validator: Validators.verificationCode,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Nova palavra-passe',
                    hint: 'Pelo menos 6 caracteres',
                    icon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    isPassword: true,
                    isRequired: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Confirmar palavra-passe',
                    hint: 'Repete a palavra-passe',
                    icon: Icons.lock_outline_rounded,
                    controller: _confirmController,
                    isPassword: true,
                    isRequired: true,
                    validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(label: 'Mudar palavra-passe', showArrow: true, onPressed: _resetPassword),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
