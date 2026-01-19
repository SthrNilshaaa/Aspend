// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionHistoryAdapter extends TypeAdapter<DetectionHistory> {
  @override
  final int typeId = 5;

  @override
  DetectionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionHistory(
      text: fields[0] as String,
      timestamp: fields[1] as DateTime,
      status: fields[2] as String,
      reason: fields[3] as String?,
      packageName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.reason)
      ..writeByte(4)
      ..write(obj.packageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
