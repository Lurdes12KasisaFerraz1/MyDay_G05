import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Cartão do Diário com os dias seguidos de estudo e a semana atual.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streakDays,
    required this.entriesThisWeek,
    required this.weekActivity,
  });

  final int streakDays;
  final int entriesThisWeek;
  final List<bool> weekActivity;

  static const List<String> _weekdayInitials = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A8BF2), AppColors.primary, Color(0xFF0A4CA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x29F2B33D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakDays dias seguidos',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      '$entriesThisWeek registos esta semana',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFE8E9EC)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var day = 0; day < 7; day++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: weekActivity[day] ? AppColors.gold : const Color(0x4DFFFFFF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _weekdayInitials[day],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: day == today ? FontWeight.w800 : FontWeight.w600,
                            color: day == today ? Colors.white : const Color(0xFFE8E9EC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
