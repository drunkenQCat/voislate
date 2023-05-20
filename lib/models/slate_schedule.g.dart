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
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.fix)
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
    final length = reader.readByte();
    final data = List<ScheduleItem>.generate(length, (_) {
      final key = reader.readString();
      final fix = reader.readString();
      final note = reader.read() as Note;
      return ScheduleItem(key, fix, note);
    });
    return DataList(data);
  }

  @override
  void write(BinaryWriter writer, DataList obj) {
    writer
      ..writeByte(obj._data.length)
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
    final length = reader.readByte();
    final data = List<ScheduleItem>.generate(length, (_) {
      final key = reader.readString();
      final fix = reader.readString();
      final note = reader.read() as Note;
      return ScheduleItem(key, fix, note);
    });
    final info = reader.read() as ScheduleItem;
    return SceneSchedule(data, info);
  }

  @override
  void write(BinaryWriter writer, SceneSchedule obj) {
    writer.writeByte(obj.data.length);
    for (final item in obj.data) {
      writer.writeString(item.key);
      writer.writeString(item.fix);
      writer.write(item.note);
    }
    writer.write(obj.info);
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
