class EntryList {
  EntryList({
      this.EntryID,
      this.ExceptionID,
      this.ExceptionLevel,});

  EntryList.fromJson(dynamic json) {
    EntryID = json['EntryID'];
    ExceptionID = json['ExceptionID'];
    ExceptionLevel = json['ExceptionLevel'];

  }
  String? EntryID;
  String? ExceptionID;
  String? ExceptionLevel;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EntryID'] = EntryID;
    map['ExceptionID'] = ExceptionID;
    map['ExceptionLevel'] = ExceptionLevel;

    return map;
  }

}