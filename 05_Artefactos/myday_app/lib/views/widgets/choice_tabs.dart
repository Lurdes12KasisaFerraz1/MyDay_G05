import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Linha de opções em forma de pílula; a opção escolhida fica destacada.
class ChoiceTabs<T> extends StatelessWidget {
  const ChoiceTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _ChoiceTab(
            label: labelOf(option),
            isSelected: option == selected,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class _ChoiceTab extends StatelessWidget {
  const _ChoiceTab({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? const Color(0x29FFFFFF) : const Color(0x0FFFFFFF),
        shape: StadiumBorder(
          side: BorderSide(color: isSelected ? const Color(0x3DFFFFFF) : AppColors.surfaceBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
