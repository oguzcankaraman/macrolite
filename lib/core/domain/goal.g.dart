// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 8;

  @override
  Goal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Goal.loseWeight;
      case 1:
        return Goal.maintain;
      case 2:
        return Goal.gainMuscle;
      default:
        return Goal.loseWeight;
    }
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    switch (obj) {
      case Goal.loseWeight:
        writer.writeByte(0);
        break;
      case Goal.maintain:
        writer.writeByte(1);
        break;
      case Goal.gainMuscle:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
