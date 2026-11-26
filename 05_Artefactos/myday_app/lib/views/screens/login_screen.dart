import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_exception.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/messages.dart';
import '../../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/photo_header.dart';
import '../widgets/round_icon_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _keepSession = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      showInvalidFormAlert(context);
      return;
    }

    try {
      widget.authController.startLogin(_emailController.text, _passwordController.text);
      Navigator.pushNamed(context, AppRoutes.verifyCode);
    } on AppException catch (error) {
      _passwordController.clear();
      showErrorAlert(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PhotoHeader(
                imagePath: AppImages.login,
                height: 236,
                alignment: const Alignment(0, -0.4),
                child: _HeaderContent(onBack: () => Navigator.maybePop(context)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bem-vindo de volta', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text(
                        'Entra para continuar o teu diário.',
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Email',
                        hint: 'nome@iade.pt',
                        icon: Icons.mail_outline_rounded,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Palavra-passe',
                        hint: 'A tua palavra-passe',
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        isPassword: true,
                        isRequired: true,
                        validator: (value) => Validators.requiredField(value, 'Escreve a tua palavra-passe'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _keepSession,
                            activeColor: AppColors.primary,
                            onChanged: (value) => setState(() => _keepSession = value ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'Manter sessão iniciada',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                            child: const Text(
                              'Esqueceste-te?',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.link),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GradientButton(label: 'Entrar', showArrow: true, onPressed: _login),
                      const SizedBox(height: 18),
                      const _Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              onPressed: () => showNotAvailable(context, 'A entrada com Google'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              label: 'Apple',
                              icon: Icons.apple_rounded,
                              onPressed: () => showNotAvailable(context, 'A entrada com Apple'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FooterLink(
                        text: 'Ainda não tens conta?',
                        action: 'Criar conta',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar', onPressed: onBack),
          const Spacer(),
          Row(
            children: [
              Image.asset(AppImages.logoIcon, height: 36),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(AppImages.logoWordmark, height: 16, semanticLabel: 'MyDay'),
                  const SizedBox(height: 4),
                  const Text(
                    'O teu diário de aprendizagem',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.glassBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou continua com', style: TextStyle(fontSize: 12, color: AppColors.textSubtle)),
        ),
        Expanded(child: Divider(color: AppColors.glassBorder)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.glass,
          side: const BorderSide(color: AppColors.glassBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
