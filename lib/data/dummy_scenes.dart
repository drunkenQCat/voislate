import '../models/slate_schedule.dart';
// the default data for the scene schedule
ScheduleItem sceneInfo1A = ScheduleItem(
  '1',
  'A',
  Note(
    objects: ['缪尔赛斯', '塞雷娅', '克里斯滕'],
    type: '万星园',
    append: '三人会面，缪尔赛斯提出了她的计划，塞雷娅和克里斯滕都表示了支持。',
  ),
);

ScheduleItem shotInfo1A = ScheduleItem(
  '1',
  'A',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '近景',
    append: '小插曲',
  ),
);

ScheduleItem shotInfo2B = ScheduleItem(
  '2',
  'B',
  Note(
    objects: ['克里斯滕', '塞雷娅'],
    type: '特写',
    append: '两人对峙',
  ),
);

ScheduleItem shotInfo3C = ScheduleItem(
  '3',
  'C',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '中景',
    append: '缪尔赛斯向塞雷娅介绍生态园',
  ),
);

ScheduleItem sceneInfo2A = ScheduleItem(
  '2',
  'A',
  Note(
    objects: ['Dr', '凯尔希', '迷迭香'],
    type: '洛肯实验室',
    append: '三人准备准备会面洛肯',
  ),
);

ScheduleItem twoAshotInfo1A = ScheduleItem(
  '1',
  'A',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '近景',
    append: '小插曲',
  ),
);

ScheduleItem twoAshotInfo2B = ScheduleItem(
  '2',
  'B',
  Note(
    objects: ['克里斯滕', '塞雷娅'],
    type: '特写',
    append: '两人对峙',
  ),
);

ScheduleItem twoAshotInfo3C = ScheduleItem(
  '3',
  'C',
  Note(
    objects: ['缪尔赛斯', '塞雷娅'],
    type: '中景',
    append: '缪尔赛斯向塞雷娅介绍生态园',
  ),
);

SceneSchedule sceneSchedule = SceneSchedule(
  [shotInfo1A, shotInfo2B, shotInfo3C],
  sceneInfo1A,
);
SceneSchedule scene2ASchedule = SceneSchedule(
  [twoAshotInfo1A, shotInfo2B, shotInfo3C],
  sceneInfo1A,
);

