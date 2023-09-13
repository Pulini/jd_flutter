/// WorkshopLocation : "待维护"
/// Group : "金焕裁断3组"
/// ProcessFlow : "面部裁断"
/// LineLeader : "谭金华"
/// TodayTargetProduction : 2876.0
/// TodayProduction : 0.0
/// CompletionRate : "0%"
/// MonthlyCumulativeTargetProduction : 6920.0
/// MonthlyCumulativeProduction : 4206.0
/// MonthlyCompletionRate : "60.7803%"
/// ActualPeopleNumber : 18
/// DepartmentID : "543247"

class ProductionSummaryInfo {
  ProductionSummaryInfo({
      this.workshopLocation, 
      this.group, 
      this.processFlow, 
      this.lineLeader, 
      this.todayTargetProduction, 
      this.todayProduction, 
      this.completionRate, 
      this.monthlyTargetProduction,
      this.monthlyProduction,
      this.monthlyCompletionRate, 
      this.actualPeopleNumber, 
      this.departmentID,});

  ProductionSummaryInfo.fromJson(dynamic json) {
    workshopLocation = json['WorkshopLocation'];
    group = json['Group'];
    processFlow = json['ProcessFlow'];
    lineLeader = json['LineLeader'];
    todayTargetProduction = json['TodayTargetProduction'];
    todayProduction = json['TodayProduction'];
    completionRate = json['CompletionRate'];
    monthlyTargetProduction = json['MonthlyCumulativeTargetProduction'];
    monthlyProduction = json['MonthlyCumulativeProduction'];
    monthlyCompletionRate = json['MonthlyCompletionRate'];
    actualPeopleNumber = json['ActualPeopleNumber'];
    departmentID = json['DepartmentID'];
  }
  String? workshopLocation;
  String? group;
  String? processFlow;
  String? lineLeader;
  double? todayTargetProduction;
  double? todayProduction;
  String? completionRate;
  double? monthlyTargetProduction;
  double? monthlyProduction;
  String? monthlyCompletionRate;
  int? actualPeopleNumber;
  String? departmentID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkshopLocation'] = workshopLocation;
    map['Group'] = group;
    map['ProcessFlow'] = processFlow;
    map['LineLeader'] = lineLeader;
    map['TodayTargetProduction'] = todayTargetProduction;
    map['TodayProduction'] = todayProduction;
    map['CompletionRate'] = completionRate;
    map['MonthlyCumulativeTargetProduction'] = monthlyTargetProduction;
    map['MonthlyCumulativeProduction'] = monthlyProduction;
    map['MonthlyCompletionRate'] = monthlyCompletionRate;
    map['ActualPeopleNumber'] = actualPeopleNumber;
    map['DepartmentID'] = departmentID;
    return map;
  }

}