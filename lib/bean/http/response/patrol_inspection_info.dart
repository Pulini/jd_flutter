//[{
// 	"produceUnitName": "针车1组",
// 	"produceUnitId": "zc01",
// 	"abnormalRecords": [{
// 		"abnormalItemId": "YP001",
// 		"abnormalRecordId": "YL001",
// 		"recordDate": "2025-05-05 20:30:29"
//
// 	}, {
// 		"abnormalItemId": "YP002",
// 		"abnormalRecordId": "YL002",
// 		"recordDate": "2025-05-05 20:30:29"
// 	}],
// 	"abnormalItems": [{
// 		"abnormalItemId": "YP001",
// 		"abnormalDescription": "Surface Defect",
// 		"monthlyDefectRate": 0.05
// 	}, {
// 		"abnormalItemId": "YP002",
// 		"abnormalDescription": "Size Mismatch",
// 		"monthlyDefectRate": 0.02
// 	}]
// }, {
// 	"produceUnitName": "针车2组",
// 	"produceUnitId": "zc02",
// 	"abnormalRecords": [{
// 		"abnormalItemId": "YP001",
// 		"abnormalRecordId": "YL001",
// 		"recordDate": "2025-05-05 20:30:29"
//
// 	}, {
// 		"abnormalItemId": "YP002",
// 		"abnormalRecordId": "YL002",
// 		"recordDate": "2025-05-05 20:30:29"
// 	}],
//
// 	"abnormalItems": [{
// 		"abnormalItemId": "YP001",
// 		"abnormalDescription": "Surface Defect",
// 		"monthlyDefectRate": 0.05
// 	}, {
// 		"abnormalItemId": "YP002",
// 		"abnormalDescription": "Size Mismatch",
// 		"monthlyDefectRate": 0.02
// 	}]
// }]
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';

class PatrolInspectionInfo {
  RxBool isSelected = false.obs;
  String? produceUnitName;
  String? produceUnitId;
  List<PatrolInspectionAbnormalRecordInfo>? abnormalRecords;
  List<PatrolInspectionAbnormalItemInfo>? abnormalItems;

  PatrolInspectionInfo({
    this.produceUnitName,
    this.produceUnitId,
    this.abnormalRecords,
    this.abnormalItems,
  }) {
    isSelected.value =
        produceUnitId == (spGet(spSavePatrolInspectionLineId) ?? '');
  }

  factory PatrolInspectionInfo.fromJson(dynamic json) {
    return PatrolInspectionInfo(
      produceUnitName: json['PRODUCEUNITNAME'],
      produceUnitId: json['PRODUCEUNITID'],
      abnormalRecords: [
        if (json['ABNORMALRECORDS'] != null)
          for (var sub in json['ABNORMALRECORDS'])
            PatrolInspectionAbnormalRecordInfo.fromJson(sub)
      ],
      abnormalItems: [
        if (json['ABNORMALITEMS'] != null)
          for (var i = 0; i < json['ABNORMALITEMS'].length; ++i)
            PatrolInspectionAbnormalItemInfo.fromJsonIndex(
              json['ABNORMALITEMS'],
              i,
            )
      ],
    );
  }

  @override
  String toString() {
    return produceUnitName ?? '';
  }
}

//{
// 		"abnormalItemId": "YP002",
// 		"abnormalRecordId": "YL002",
// 		"recordDate": "2025-05-05 20:30:29"
// 	}
class PatrolInspectionAbnormalRecordInfo {
  String? abnormalItemId;
  String? abnormalRecordId;
  String? recordDate;

  PatrolInspectionAbnormalRecordInfo({
    this.abnormalItemId,
    this.abnormalRecordId,
    this.recordDate,
  });

  factory PatrolInspectionAbnormalRecordInfo.fromJson(dynamic json) {
    return PatrolInspectionAbnormalRecordInfo(
      abnormalItemId: json['ABNORMALITEMID'],
      abnormalRecordId: json['ABNORMALRECORDID'],
      recordDate: json['RECORDDATE'],
    );
  }
}

//{
// 		"abnormalItemId": "YP001",
// 		"abnormalDescription": "Surface Defect",
// 		"monthlyDefectRate": 0.05
// 	}
class PatrolInspectionAbnormalItemInfo {
  RxString tag = ''.obs;
  String? abnormalItemId;
  String? abnormalDescription;
  double? monthlyDefectRate;

  PatrolInspectionAbnormalItemInfo({
    this.abnormalItemId,
    this.abnormalDescription,
    this.monthlyDefectRate,
  });

  factory PatrolInspectionAbnormalItemInfo.fromJson(dynamic json) {
    return PatrolInspectionAbnormalItemInfo(
      abnormalItemId: json['ABNORMALITEMID'],
      abnormalDescription: json['ABNORMALDESCRIPTION'],
      monthlyDefectRate: json['MONTHLYDEFECTRATE'].toString().toDoubleTry(),
    );
  }

  factory PatrolInspectionAbnormalItemInfo.fromJsonIndex(
      dynamic json, int index) {
    var data = PatrolInspectionAbnormalItemInfo(
      abnormalItemId: json[index]['ABNORMALITEMID'],
      abnormalDescription: json[index]['ABNORMALDESCRIPTION'],
      monthlyDefectRate:
          json[index]['MONTHLYDEFECTRATE'].toString().toDoubleTry(),
    );
    var saveTag = spGet('PI-${data.abnormalItemId}-${userInfo?.number}');
    if (saveTag != null && saveTag.toString().isNotEmpty) {
      data.tag.value = saveTag;
    } else {
      data.tag.value = '${index + 1}';
    }
    return data;
  }

  String getDefectRate() => '${monthlyDefectRate.toShowString()}%';
}
