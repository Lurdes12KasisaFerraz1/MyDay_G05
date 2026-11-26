import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Campo de texto com etiqueta por cima, usado nos formulários.
///
/// Os campos obrigatórios mostram um asterisco. Quando a validação falha, a
/// etiqueta, o contorno e a mensagem ficam a vermelho.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hint,
    this.isPassword = false,
    this.isRequired = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.textStyle,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hint;
  final bool isPassword;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;
  final TextStyle? textStyle;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;
  bool _hasError = false;

  OutlineInputBorder _border(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  String? _validate(String? value) {
    final error = widget.validator?.call(value);
    final hasError = error != null;
    if (hasError != _hasError) {
      // A validação corre durante o build do Form, por isso a etiqueta só é
      // atualizada no frame seguinte.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _hasError = hasError);
      });
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            children: [
              if (widget.isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: AppColors.errorBorder)),
            ],
          ),
          style: _hasError ? labelStyle?.copyWith(color: AppColors.error) : labelStyle,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator == null ? null : _validate,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          style: widget.textStyle ??
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.textSubtle),
            counterText: '',
            filled: true,
            fillColor: _hasError ? const Color(0x14F2555A) : const Color(0x0FFFFFFF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20, color: _hasError ? AppColors.error : AppColors.textSubtle),
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: _obscured ? 'Mostrar palavra-passe' : 'Esconder palavra-passe',
                    icon: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSubtle,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
            enabledBorder: _border(AppColors.glassBorder),
            focusedBorder: _border(const Color(0xFF4C9BFF)),
            errorBorder: _border(AppColors.errorBorder),
            focusedErrorBorder: _border(AppColors.errorBorder),
          ),
        ),
      ],
    );
  }
}
