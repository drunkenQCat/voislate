// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slate_log_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SlateLogItemAdapter extends TypeAdapter<SlateLogItem> {
  @override
  final int typeId = 6;

  @override
  SlateLogItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SlateLogItem(
      scn: fields[0] as String,
      sht: fields[1] as String,
      tk: fields[2] as int,
      filenamePrefix: fields[3] as String,
      filenameLinker: fields[4] as String,
      filenameNum: fields[5] as int,
      tkNote: fields[6] as String,
      shtNote: fields[7] as String,
      scnNote: fields[8] as String,
      currentOkTk: fields[9] as TkStatus,
      currentOkSht: fields[10] as ShtStatus,
    );
  }

  @override
  void write(BinaryWriter writer, SlateLogItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.scn)
      ..writeByte(1)
      ..write(obj.sht)
      ..writeByte(2)
      ..write(obj.tk)
      ..writeByte(3)
      ..write(obj.filenamePrefix)
      ..writeByte(4)
      ..write(obj.filenameLinker)
      ..writeByte(5)
      ..write(obj.filenameNum)
      ..writeByte(6)
      ..write(obj.tkNote)
      ..writeByte(7)
      ..write(obj.shtNote)
      ..writeByte(8)
      ..write(obj.scnNote)
      ..writeByte(9)
      ..write(obj.okTk)
      ..writeByte(10)
      ..write(obj.okSht);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlateLogItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TkStatusAdapter extends TypeAdapter<TkStatus> {
  @override
  final int typeId = 4;

  @override
  TkStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TkStatus.notChecked;
      case 1:
        return TkStatus.ok;
      case 2:
        return TkStatus.bad;
      default:
        return TkStatus.notChecked;
    }
  }

  @override
  void write(BinaryWriter writer, TkStatus obj) {
    switch (obj) {
      case TkStatus.notChecked:
        writer.writeByte(0);
        break;
      case TkStatus.ok:
        writer.writeByte(1);
        break;
      case TkStatus.bad:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TkStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShtStatusAdapter extends TypeAdapter<ShtStatus> {
  @override
  final int typeId = 5;

  @override
  ShtStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShtStatus.notChecked;
      case 1:
        return ShtStatus.ok;
      case 2:
        return ShtStatus.nice;
      default:
        return ShtStatus.notChecked;
    }
  }

  @override
  void write(BinaryWriter writer, ShtStatus obj) {
    switch (obj) {
      case ShtStatus.notChecked:
        writer.writeByte(0);
        break;
      case ShtStatus.ok:
        writer.writeByte(1);
        break;
      case ShtStatus.nice:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShtStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
