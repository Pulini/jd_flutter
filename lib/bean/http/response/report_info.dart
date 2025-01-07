class ReportInfo {
  ReportInfo({
    this.rowIndex,
    this.backgroundColor,
    this.dataList,
  });

  ReportInfo.fromJson(dynamic json) {
    rowIndex = json['RowIndex'];
    backgroundColor = json['BackgroundColor'];
    if (json['DataList'] != null) {
      dataList = [];
      json['DataList'].forEach((v) {
        dataList?.add(DataList.fromJson(v));
      });
    }
  }

  int? rowIndex = 0;
  String? backgroundColor = '#ffffff';
  List<DataList>? dataList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['RowIndex'] = rowIndex;
    map['BackgroundColor'] = backgroundColor;
    if (dataList != null) {
      map['DataList'] = dataList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class DataList {
  DataList({
    this.content,
    this.fieldName,
    this.width,
    this.visible,
    this.colIndex,
    this.caption,
    this.foreColor,
  });

  DataList.fromJson(dynamic json) {
    content = json['Content'];
    fieldName = json['FieldName'];
    width = json['Width'];
    visible = json['Visible'];
    colIndex = json['ColIndex'];
    caption = json['Caption'];
    foreColor = json['ForeColor'];
  }

  String? content;
  String? fieldName;
  int? width;
  bool? visible;
  int? colIndex;
  String? caption;
  String? foreColor;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Content'] = content;
    map['FieldName'] = fieldName;
    map['Width'] = width;
    map['Visible'] = visible;
    map['ColIndex'] = colIndex;
    map['Caption'] = caption;
    map['ForeColor'] = foreColor;

    return map;
  }
}
