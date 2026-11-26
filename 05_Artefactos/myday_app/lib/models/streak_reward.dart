/// Recompensa desbloqueada ao atingir um número de dias seguidos com registos.
class StreakReward {
  const StreakReward({required this.days, required this.title, required this.description});

  final int days;
  final String title;
  final String description;
}
