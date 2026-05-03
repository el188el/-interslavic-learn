class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.xp,
    required this.streak,
    this.isCurrentUser = false,
  });

  final String name;
  final int xp;
  final int streak;
  final bool isCurrentUser;
}
