// GENERATED CODE — hand-written Hive TypeAdapter for UserProgress

part of 'user_progress.dart';

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      supabaseUserId: fields[0] as String? ?? '',
      totalXp: fields[1] as int? ?? 0,
      currentStreak: fields[2] as int? ?? 0,
      bestStreak: fields[3] as int? ?? 0,
      lastActiveDate: fields[4] as String? ?? '',
      completedLessons:
          (fields[5] as List?)?.cast<String>().toList() ?? [],
      lessonScores:
          (fields[6] as Map?)?.cast<String, int>() ?? {},
      displayName: fields[7] as String? ?? 'Ученик',
      isPremium: fields[8] as bool? ?? false,
      lessonCheckpoints:
          (fields[9] as Map?)?.cast<String, String>() ?? {},
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.supabaseUserId)
      ..writeByte(1)
      ..write(obj.totalXp)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.bestStreak)
      ..writeByte(4)
      ..write(obj.lastActiveDate)
      ..writeByte(5)
      ..write(obj.completedLessons)
      ..writeByte(6)
      ..write(obj.lessonScores)
      ..writeByte(7)
      ..write(obj.displayName)
      ..writeByte(8)
      ..write(obj.isPremium)
      ..writeByte(9)
      ..write(obj.lessonCheckpoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
