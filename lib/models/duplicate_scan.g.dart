// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_scan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DuplicateScanEventAdapter extends TypeAdapter<DuplicateScanEvent> {
  @override
  final int typeId = 7;

  @override
  DuplicateScanEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DuplicateScanEvent(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      userName: fields[2] as String,
      normalizedUserName: fields[3] as String,
      action: fields[4] as String,
      scannedCode: fields[5] as String,
      originalLineNumber: fields[6] as int?,
      handlingMode: fields[7] as String,
      result: fields[8] as String,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DuplicateScanEvent obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.normalizedUserName)
      ..writeByte(4)
      ..write(obj.action)
      ..writeByte(5)
      ..write(obj.scannedCode)
      ..writeByte(6)
      ..write(obj.originalLineNumber)
      ..writeByte(7)
      ..write(obj.handlingMode)
      ..writeByte(8)
      ..write(obj.result)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuplicateScanEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DuplicateHandlingModeAdapter extends TypeAdapter<DuplicateHandlingMode> {
  @override
  final int typeId = 6;

  @override
  DuplicateHandlingMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DuplicateHandlingMode.blockDuplicates;
      case 1:
        return DuplicateHandlingMode.warnBeforeAdding;
      case 2:
        return DuplicateHandlingMode.mergeDuplicates;
      case 3:
        return DuplicateHandlingMode.allowDuplicates;
      default:
        return DuplicateHandlingMode.blockDuplicates;
    }
  }

  @override
  void write(BinaryWriter writer, DuplicateHandlingMode obj) {
    switch (obj) {
      case DuplicateHandlingMode.blockDuplicates:
        writer.writeByte(0);
        break;
      case DuplicateHandlingMode.warnBeforeAdding:
        writer.writeByte(1);
        break;
      case DuplicateHandlingMode.mergeDuplicates:
        writer.writeByte(2);
        break;
      case DuplicateHandlingMode.allowDuplicates:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuplicateHandlingModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
