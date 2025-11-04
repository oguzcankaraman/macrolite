// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_unit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodUnitAdapter extends TypeAdapter<FoodUnit> {
  @override
  final int typeId = 0;

  @override
  FoodUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodUnit.gram;
      case 1:
        return FoodUnit.milliliter;
      case 2:
        return FoodUnit.piece;
      case 3:
        return FoodUnit.serving;
      default:
        return FoodUnit.gram;
    }
  }

  @override
  void write(BinaryWriter writer, FoodUnit obj) {
    switch (obj) {
      case FoodUnit.gram:
        writer.writeByte(0);
        break;
      case FoodUnit.milliliter:
        writer.writeByte(1);
        break;
      case FoodUnit.piece:
        writer.writeByte(2);
        break;
      case FoodUnit.serving:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
