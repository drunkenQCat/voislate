// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slate_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleItemAdapter extends TypeAdapter<ScheduleItem> {
  @override
  final int typeId = 0;

  @override
  ScheduleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleItem(
      fields[0] as String,
      fields[1] as String,
      fields[3] as Note,
    )..name = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, ScheduleItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj._key)
      ..writeByte(1)
      ..write(obj._fix)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 1;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      objects: (fields[0] as List).cast<String>(),
      type: fields[1] as String,
      append: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.objects)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.append);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataListAdapter extends TypeAdapter<DataList> {
  @override
  final int typeId = 2;

  @override
  DataList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataList((fields[0] as List).cast<ScheduleItem>());
  }

  @override
  void write(BinaryWriter writer, DataList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SceneScheduleAdapter extends TypeAdapter<SceneSchedule> {
  @override
  final int typeId = 3;

  @override
  SceneSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SceneSchedule(
      (fields[0] as List).cast<ScheduleItem>(),
      fields[1] as ScheduleItem,
    );
  }

  @override
  void write(BinaryWriter writer, SceneSchedule obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.info)
      ..writeByte(0)
      ..write(obj._data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SceneScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
