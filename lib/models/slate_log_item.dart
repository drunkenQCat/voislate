enum TkStatus {
  notChecked,
  ok,
  bad,
}

enum ShtStatus {
  notChecked,
  ok,
  nice,
}

class SlateLogItem {
  String scn;
  String sht;
  int tk;
  String filenamePrefix;
  String filenameLinker;
  int filenameNum;
  String tkNote;
  String shtNote;
  String scnNote;
  TkStatus okTk;
  ShtStatus okSht;

  SlateLogItem({
    required this.scn,
    required this.sht,
    required this.tk,
    required this.filenamePrefix,
    required this.filenameLinker,
    required this.filenameNum,
    required this.tkNote,
    required this.shtNote,
    required this.scnNote,
    required this.okTk,
    required this.okSht,
  });
}
