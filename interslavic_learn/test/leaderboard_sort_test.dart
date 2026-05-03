import 'package:flutter_test/flutter_test.dart';
import 'package:interslavic_learn/screens/leaderboard/leaderboard_data.dart';
import 'package:interslavic_learn/screens/leaderboard/leaderboard_entry.dart';

void main() {
  test('sortLeaderboardByXpDesc orders by XP descending', () {
    final list = [
      const LeaderboardEntry(name: 'a', xp: 10, streak: 0),
      const LeaderboardEntry(name: 'b', xp: 50, streak: 1),
      const LeaderboardEntry(name: 'c', xp: 30, streak: 0),
    ];
    sortLeaderboardByXpDesc(list);
    expect(list.map((e) => e.name), ['b', 'c', 'a']);
  });
}
