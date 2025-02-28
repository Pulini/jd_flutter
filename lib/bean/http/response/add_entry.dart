class EntryList {
  EntryList({
      this.entryID,
      this.exceptionID,
      this.exceptionLevel,});

  EntryList.fromJson(dynamic json) {
    entryID = json['EntryID'];
    exceptionID = json['ExceptionID'];
    exceptionLevel = json['ExceptionLevel'];

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