// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_food.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoggedFoodAdapter extends TypeAdapter<LoggedFood> {
  @override
  final int typeId = 1;

  @override
  LoggedFood read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoggedFood(
      name: fields[0] as String,
      quantity: fields[1] as double,
      unit: fields[2] as FoodUnit,
      calories: fields[3] as int,
      protein: fields[4] as double,
      carbs: fields[5] as double,
      fat: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LoggedFood obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.carbs)
      ..writeByte(6)
      ..write(obj.fat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedFoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
