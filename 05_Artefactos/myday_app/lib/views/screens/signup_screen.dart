import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../models/enums.dart';
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const List<String> _courses = ['Eng. Informática · IADE', 'Design · IADE'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  String _course = _courses.first;
  VerificationChannel _channel = VerificationChannel.email;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    final isValid = _formKey.currentState!.validate();
    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _showTermsError = !_acceptedTerms;
    });
    if (!isValid || !_acceptedTerms) {
      showInvalidFormAlert(context);
      return;
    }

    try {
      widget.authController.startRegistration(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        course: _course,
        channel: _channel,
      );
      Navigator.pushNamed(context, AppRoutes.verifyCode);
    } on AppException catch (error) {
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
                imagePath: AppImages.signup,
                height: 224,
                alignment: const Alignment(0.6, -0.6),
                child: _HeaderContent(onBack: () => Navigator.maybePop(context)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Nome',
                        hint: 'O teu nome',
                        icon: Icons.person_outline_rounded,
                        controller: _nameController,
                        isRequired: true,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Email',
                        hint: 'nome@iade.pt',
                        icon: Icons.mail_outline_rounded,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Telemóvel',
                        hint: '912 345 678',
                        icon: Icons.phone_iphone_rounded,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Palavra-passe',
                        hint: 'Pelo menos 6 caracteres',
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        isPassword: true,
                        isRequired: true,
                        validator: Validators.password,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      _PasswordStrength(strength: Validators.passwordStrength(_passwordController.text)),
                      const SizedBox(height: 12),
                      _CourseField(
                        courses: _courses,
                        value: _course,
                        onChanged: (course) => setState(() => _course = course),
                      ),
                      const SizedBox(height: 12),
                      _ChannelSelector(
                        selected: _channel,
                        onChanged: (channel) => setState(() => _channel = channel),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            activeColor: AppColors.primary,
                            side: BorderSide(
                              color: _showTermsError ? AppColors.errorBorder : AppColors.textSubtle,
                              width: 1.5,
                            ),
                            onChanged: (value) => setState(() {
                              _acceptedTerms = value ?? false;
                              _showTermsError = !_acceptedTerms;
                            }),
                          ),
                          Expanded(
                            child: Text(
                              'Aceito os Termos e a Política de Privacidade. *',
                              style: TextStyle(
                                fontSize: 13,
                                color: _showTermsError ? AppColors.error : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showTermsError)
                        const Padding(
                          padding: EdgeInsets.only(left: 12, bottom: 4),
                          child: Text(
                            'Tens de aceitar para criar conta',
                            style: TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      const SizedBox(height: 8),
                      GradientButton(label: 'Criar conta', showArrow: true, onPressed: _register),
                      const SizedBox(height: 8),
                      FooterLink(
                        text: 'Já tens conta?',
                        action: 'Entrar',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoundIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Voltar', onPressed: onBack),
              Image.asset(AppImages.logoIcon, height: 30),
            ],
          ),
          const Spacer(),
          Text('Cria a tua conta', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30)),
          const SizedBox(height: 4),
          const Text(
            'Leva menos de um minuto. Os teus registos começam privados.',
            style: TextStyle(fontSize: 15, color: Color(0xBFFFFFFF)),
          ),
        ],
      ),
    );
  }
}

/// Onde o estudante quer receber o código de confirmação.
class _ChannelSelector extends StatelessWidget {
  const _ChannelSelector({required this.selected, required this.onChanged});

  final VerificationChannel selected;
  final ValueChanged<VerificationChannel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Receber código por', style: Theme.of(context).textTheme.labelLarge),
        const Spacer(),
        for (final channel in VerificationChannel.values) ...[
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(channel == VerificationChannel.email ? 'Email' : 'SMS'),
            selected: channel == selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(channel),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.glass,
            side: const BorderSide(color: AppColors.glassBorder),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ],
    );
  }
}

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.strength});

  final int strength;

  static const List<String> _labels = ['Muito fraca', 'Fraca', 'Média · junta um símbolo', 'Boa', 'Forte'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: i < strength ? AppColors.gold : const Color(0x29FFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _labels[strength],
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF2C86B)),
        ),
      ],
    );
  }
}

class _CourseField extends StatelessWidget {
  const _CourseField({required this.courses, required this.value, required this.onChanged});

  final List<String> courses;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Curso', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSubtle),
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.school_outlined, size: 20, color: AppColors.textSubtle),
            filled: true,
            fillColor: const Color(0x0FFFFFFF),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.glassBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4C9BFF), width: 1.5),
            ),
          ),
          items: [
            for (final course in courses) DropdownMenuItem(value: course, child: Text(course)),
          ],
          onChanged: (course) {
            if (course != null) onChanged(course);
          },
        ),
      ],
    );
  }
}
