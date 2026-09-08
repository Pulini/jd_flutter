import 'package:jd_flutter/utils/extension_util.dart';
class EntryList {
  EntryList({
      this.entryID,
      this.exceptionID,
      this.exceptionLevel,});

  EntryList.fromJson(dynamic json) {
    entryID = JsonParse.str(json['EntryID']);
    exceptionID = JsonParse.str(json['ExceptionID']);
    exceptionLevel = JsonParse.str(json['ExceptionLevel']);

  }
  String? entryID;
  String? exceptionID;
  String? exceptionLevel;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EntryID'] = entryID;
    map['ExceptionID'] = exceptionID;
    map['ExceptionLevel'] = exceptionLevel;

    return map;
  }

}