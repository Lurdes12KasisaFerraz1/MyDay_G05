import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Barra de navegação inferior. O separador ativo fica num botão azul.
/// Quando [onCreateEntry] é indicado, aparece o botão "+" ao centro.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreateEntry,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCreateEntry;

  static const List<_NavItem> _items = [
    _NavItem('Diário', Icons.menu_book_rounded),
    _NavItem('Projetos', Icons.folder_outlined),
    _NavItem('Comunidade', Icons.groups_outlined),
    _NavItem('Perfil', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++) ...[
                if (i == 2 && onCreateEntry != null) _CreateButton(onPressed: onCreateEntry!),
                _NavButton(
                  item: _items[i],
                  isActive: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.primaryGlow,
      ),
      child: IconButton(
        tooltip: 'Novo registo',
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.isActive, required this.onTap});

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : AppColors.textSubtle;

    return Semantics(
      selected: isActive,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 70),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? AppColors.primaryGlow : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
