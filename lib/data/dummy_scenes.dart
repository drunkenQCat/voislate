import '../models/slate_schedule.dart';


final SceneSchedule defaultScenes = SceneSchedule(
  list: [
    ScheduleItem('1', 'A',
        Note(objects: ['男主角', '女主角', '猫猫'], type: '会议室', append: '开会场景')),
    ScheduleItem('2', 'A',
        Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
    ScheduleItem('3', 'A',
        Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
  ],
  shots: [
    ShotSchedule([
      ScheduleItem('1', 'A',
          Note(objects: ['男主'], type: '近景', append: '在会议室开会')),
      ScheduleItem('2', 'A',
          Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
      ScheduleItem('3', 'A',
          Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
      ScheduleItem('4', 'A',
          Note(objects: ['Object 4'], type: 'Type 4', append: 'Append 4')),
      ScheduleItem('5', 'A',
          Note(objects: ['Object 5'], type: 'Type 5', append: 'Append 5')),
    ]),
    ShotSchedule([
      ScheduleItem('2', 'A',
          Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
      ScheduleItem('6', 'A',
          Note(objects: ['Object 6'], type: 'Type 6', append: 'Append 6')),
      ScheduleItem('7', 'A',
          Note(objects: ['Object 7'], type: 'Type 7', append: 'Append 7')),
      ScheduleItem('8', 'A',
          Note(objects: ['Object 8'], type: 'Type 8', append: 'Append 8')),
      ScheduleItem('9', 'A',
          Note(objects: ['Object 9'], type: 'Type 9', append: 'Append 9')),
    ]),
    ShotSchedule([
      ScheduleItem('3', 'A',
          Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
      ScheduleItem('10', 'A',
          Note(objects: ['Object 10'], type: 'Type 10', append: 'Append 10')),
      ScheduleItem('11', 'A',
          Note(objects: ['Object 11'], type: 'Type 11', append: 'Append 11')),
      ScheduleItem('12', 'A',
          Note(objects: ['Object 12'], type: 'Type 12', append: 'Append 12')),
      ScheduleItem('13', 'A',
          Note(objects: ['Object 13'], type: 'Type 13', append: 'Append 13')),
      ScheduleItem('14', 'A',
          Note(objects: ['Object 14'], type: 'Type 14', append: 'Append 14')),
    ]),
  ],
);

List<String> scnNums = [];
List<String> shtNums = [];
List<int> tkNums = [];

int defaultScnIdx = 0;
int defaultShtIdx = 0;
int defaultTkIdx = 0;