import 'package:flutter/material.dart';

import '../../controllers/diary_controller.dart';
import '../../models/streak_reward.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/date_formatter.dart';
import '../widgets/app_background.dart';
import '../widgets/entry_card.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/section_header.dart';

/// Calendário dos registos, com a sequência de dias seguidos e as recompensas.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.diaryController});

  final DiaryController diaryController;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final diary = widget.diaryController;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: diary,
            builder: (context, _) {
              final dayEntries = diary.entriesOn(_selectedDay);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Text('Calendário', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _StreakHero(
                    currentStreak: diary.currentStreak,
                    bestStreak: diary.bestStreak,
                    nextReward: diary.nextReward,
                  ),
                  const SizedBox(height: 16),
                  _MonthCalendar(
                    month: _month,
                    selectedDay: _selectedDay,
                    activeDays: diary.activeDays,
                    onPrevious: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                    onDaySelected: (day) => setState(() => _selectedDay = day),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(title: 'Recompensas'),
                  const SizedBox(height: 12),
                  _RewardsGrid(bestStreak: diary.bestStreak),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: DateFormatter.longDate(_selectedDay),
                    counter: dayEntries.length == 1 ? '1 registo' : '${dayEntries.length} registos',
                  ),
                  const SizedBox(height: 12),
                  if (dayEntries.isEmpty)
                    const Text('Sem registos neste dia.', style: TextStyle(color: AppColors.textMuted)),
                  for (final entry in dayEntries) ...[
                    EntryCard(
                      entry: entry,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.entryDetail, arguments: entry),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.currentStreak, required this.bestStreak, required this.nextReward});

  final int currentStreak;
  final int bestStreak;
  final StreakReward? nextReward;

  @override
  Widget build(BuildContext context) {
    final reward = nextReward;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStreak == 1 ? '1 dia seguido' : '$currentStreak dias seguidos',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'Melhor sequência: $bestStreak dias',
                      style: const TextStyle(fontSize: 13, color: Color(0xE6FFFFFF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (reward == null)
            const Text(
              'Desbloqueaste todas as recompensas. És uma lenda!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            )
          else ...[
            Text(
              'Faltam ${reward.days - currentStreak} dias para «${reward.title}»',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: currentStreak / reward.days,
                minHeight: 8,
                backgroundColor: const Color(0x40FFFFFF),
                color: AppColors.gold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.selectedDay,
    required this.activeDays,
    required this.onPrevious,
    required this.onNext,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Set<DateTime> activeDays;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onDaySelected;

  static const List<String> _weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Espaços vazios antes do dia 1, com a semana a começar à segunda-feira.
    final leadingBlanks = DateTime(month.year, month.month).weekday - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mês anterior',
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  DateFormatter.monthYear(month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Mês seguinte',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final weekday in _weekdays)
                Expanded(
                  child: Text(
                    weekday,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSubtle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++)
                _DayCell(
                  day: DateTime(month.year, month.month, day),
                  isActive: activeDays.contains(DateTime(month.year, month.month, day)),
                  isSelected: DateFormatter.isSameDay(selectedDay, DateTime(month.year, month.month, day)),
                  onTap: onDaySelected,
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.gold),
              SizedBox(width: 4),
              Text('Dia com registo', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isActive, required this.isSelected, required this.onTap});

  final DateTime day;
  final bool isActive;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormatter.isSameDay(day, DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: isSelected
            ? Colors.white
            : isActive
                ? const Color(0x33F2B33D)
                : Colors.transparent,
        shape: CircleBorder(
          side: isToday && !isSelected ? const BorderSide(color: AppColors.primaryLight, width: 1.5) : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onTap(day),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive || isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? AppColors.background : (isActive ? Colors.white : AppColors.textSecondary),
                ),
              ),
              if (isActive)
                const Positioned(
                  bottom: 2,
                  child: Icon(Icons.local_fire_department_rounded, size: 10, color: AppColors.gold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardsGrid extends StatelessWidget {
  const _RewardsGrid({required this.bestStreak});

  final int bestStreak;

  static const List<IconData> _icons = [
    Icons.bolt_rounded,
    Icons.local_fire_department_rounded,
    Icons.whatshot_rounded,
    Icons.workspace_premium_rounded,
    Icons.rocket_launch_rounded,
    Icons.emoji_events_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    const rewards = DiaryController.rewards;

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < rewards.length; i++)
          _RewardBadge(
            reward: rewards[i],
            icon: _icons[i % _icons.length],
            unlocked: bestStreak >= rewards[i].days,
          ),
      ],
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.reward, required this.icon, required this.unlocked});

  final StreakReward reward;
  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: unlocked ? const Color(0x80F2B33D) : AppColors.surfaceBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: unlocked ? const Color(0x33F2B33D) : AppColors.glass,
            child: Icon(
              unlocked ? icon : Icons.lock_outline_rounded,
              color: unlocked ? AppColors.gold : AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reward.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: unlocked ? Colors.white : AppColors.textMuted,
            ),
          ),
          Text(reward.description, style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
        ],
      ),
    );
  }
}
