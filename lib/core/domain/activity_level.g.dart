// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLevelAdapter extends TypeAdapter<ActivityLevel> {
  @override
  final int typeId = 7;

  @override
  ActivityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityLevel.sedentary;
      case 1:
        return ActivityLevel.light;
      case 2:
        return ActivityLevel.moderate;
      case 3:
        return ActivityLevel.active;
      case 4:
        return ActivityLevel.veryActive;
      default:
        return ActivityLevel.sedentary;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityLevel obj) {
    switch (obj) {
      case ActivityLevel.sedentary:
        writer.writeByte(0);
        break;
      case ActivityLevel.light:
        writer.writeByte(1);
        break;
      case ActivityLevel.moderate:
        writer.writeByte(2);
        break;
      case ActivityLevel.active:
        writer.writeByte(3);
        break;
      case ActivityLevel.veryActive:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
