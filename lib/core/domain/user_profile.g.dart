// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      targetCalories: fields[0] as double,
      targetProtein: fields[1] as double,
      targetCarbs: fields[2] as double,
      targetFat: fields[3] as double,
      currentWeight: fields[4] as double,
      height: fields[5] as double,
      age: fields[6] as int,
      gender: fields[7] as Gender,
      activityLevel: fields[8] as ActivityLevel,
      goal: fields[9] as Goal,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.targetCalories)
      ..writeByte(1)
      ..write(obj.targetProtein)
      ..writeByte(2)
      ..write(obj.targetCarbs)
      ..writeByte(3)
      ..write(obj.targetFat)
      ..writeByte(4)
      ..write(obj.currentWeight)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.age)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.activityLevel)
      ..writeByte(9)
      ..write(obj.goal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
