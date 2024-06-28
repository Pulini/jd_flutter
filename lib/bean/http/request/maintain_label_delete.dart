class MaintainLabelDelete{
  String workCardID;
  List<String> barCodes;

  MaintainLabelDelete({
    required this.workCardID,
    required this.barCodes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkCardID'] = workCardID;
    map['BarCodes'] = barCodes;
    return map;
  }
}
