import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

//{
//   'WORKORDERNO': '002002406745',
//   'INSTRUCTIONNO': 'J2400375',
//   'TYPEBODY': 'PDW25308979-10',
//   'CUSTOMERPO': '460247403/460247404/460247406/460247410',
//   'INSPECTOR': '',
//   'INSPECTIONUNIT': '',
//   'INSPECTIONDATE': '0000-00-00',
//   'ABNORMALQTY': 0,
//   'REINSPECTIONQTY': 0,
//   'STATUS': '1'
// },
class QualityInspectionInfo {
  String? inspectionUnit; //质检单位
  List<QualityInspectionOrderInfo>? groupOrder;

  QualityInspectionInfo({
    required this.inspectionUnit,
    required this.groupOrder,
  });

  factory QualityInspectionInfo.fromJson(dynamic json) {
    return QualityInspectionInfo(
      inspectionUnit: json['INSPECTIONUNIT'],
      groupOrder: [
        if (json['GROUPORDER'] != null)
          for (var v in json['GROUPORDER'])
            QualityInspectionOrderInfo.fromJson(v)
      ],
    );
  }

  int getAbnormalQty() =>
      groupOrder!.map((v) => v.abnormalQty ?? 0).reduce((a, b) => a + b);

  int getReInspectionQty() =>
      groupOrder!.map((v) => v.reInspectionQty ?? 0).reduce((a, b) => a + b);
}

class QualityInspectionOrderInfo {
  String? workOrderNo; //工单号
  String? instructionNo; //指令号
  String? typeBody; //型体
  String? customerPo; //客户PO
  String? inspector; //质检员
  String? inspectionDate; //质检日期
  int? abnormalQty; //质检异常数
  int? reInspectionQty; //质检复查数
  String? status; //质检状态（1未质检、2质检中、3复检中、4质检完成）

  QualityInspectionOrderInfo({
    this.workOrderNo,
    this.instructionNo,
    this.customerPo,
    this.typeBody,
    this.inspectionDate,
    this.inspector,
    this.abnormalQty,
    this.reInspectionQty,
    this.status,
  });

  QualityInspectionOrderInfo.fromJson(dynamic json) {
    workOrderNo = json['WORKORDERNO'];
    instructionNo = json['INSTRUCTIONNO'];
    customerPo = json['CUSTOMERPO'];
    typeBody = json['TYPEBODY'];
    inspectionDate = json['INSPECTIONDATE'];
    inspector = json['INSPECTOR'];
    abnormalQty = json['ABNORMALQTY'];
    reInspectionQty = json['REINSPECTIONQTY'];
    status = json['STATUS'];
  }

  Color getFlagColor() {
    //1未质检、2质检中、3复检中、4质检完成
    switch (status) {
      case '1':
        return Colors.orange;
      case '2':
        return Colors.blue;
      case '3':
        return Colors.purple;
      case '4':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String getFlagText() {
    //1未质检、2质检中、3复检中、4质检完成
    switch (status) {
      case '1':
        return '未质检';
      case '2':
        return '质检中';
      case '3':
        return '复检中';
      case '4':
        return '质检完成';
      default:
        return '错误';
    }
  }
}

//{
//   'WORKORDERNO': '002002406745',
//   'INSTRUCTIONNO': 'J2400375',
//   'TYPEBODY': 'PDW25308979-10',
//   'CUSTOMERPO': '',
//   'INSPECTIONUNIT': '',
//   'TOTALQUANTITY': 700.0,
//   'ABNORMALRECORDS': [],
//   'ABNORMALITEMS': []
// }
class QualityInspectionDetailInfo {
  String? workOrderNo;
  String? instructionNo;
  String? typeBody;
  String? customerPo;
  String? inspectionUnit;
  double? totalQuantity;
  List<QualityInspectionAbnormalRecordInfo>? abnormalRecords;
  List<QualityInspectionAbnormalItemInfo>? abnormalItems;

  QualityInspectionDetailInfo({
    this.workOrderNo,
    this.instructionNo,
    this.typeBody,
    this.customerPo,
    this.inspectionUnit,
    this.totalQuantity,
    this.abnormalRecords,
  });

  QualityInspectionDetailInfo.fromJson(dynamic json) {
    workOrderNo = json['WORKORDERNO'];
    instructionNo = json['INSTRUCTIONNO'];
    typeBody = json['TYPEBODY'];
    customerPo = json['CUSTOMERPO'];
    inspectionUnit = json['INSPECTIONUNIT'];
    totalQuantity = json['TOTALQUANTITY'];
    abnormalRecords = [
      if (json['ABNORMALRECORDS'] != null)
        for (var v in json['ABNORMALRECORDS'])
          QualityInspectionAbnormalRecordInfo.fromJson(v)
    ];
    abnormalItems = [
      if (json['ABNORMALITEMS'] != null)
        // for (var v in json['ABNORMALITEMS'])
        //   QualityInspectionAbnormalItemInfo.fromJson(v)
        for (var i = 0; i < json['ABNORMALITEMS'].length; ++i)
          QualityInspectionAbnormalItemInfo.fromJsonIndex(
            json['ABNORMALITEMS'],
            i,
          )
    ];
  }
}

//    'abnormalItemId': 'YP001',
// 		'abnormalRecordId': 'YL001',
// 		'abnormalSeverity': 1,
// 		'abnormalStatus': 1
class QualityInspectionAbnormalRecordInfo {
  RxBool isSelect = false.obs;

  String? abnormalRecordId;
  String? abnormalItemId;
  int? abnormalSeverity;
  int? abnormalStatus;
  String? modifyDate;

  QualityInspectionAbnormalRecordInfo({
    this.abnormalRecordId,
    this.abnormalItemId,
    this.abnormalSeverity,
    this.abnormalStatus,
    this.modifyDate,
  });

  factory QualityInspectionAbnormalRecordInfo.fromJson(dynamic json) =>
      QualityInspectionAbnormalRecordInfo(
        abnormalRecordId: json['ABNORMALRECORDID'],
        abnormalItemId: json['ABNORMALITEMID'],
        abnormalSeverity: json['ABNORMALSEVERITY'],
        abnormalStatus: json['ABNORMALSTATUS'],
        modifyDate: json['MODIFYDATE'],
      );

  Map<String, dynamic> toJson() => {
        'isSelect': isSelect.value,
        'AbnormalRecordId': abnormalRecordId,
        'AbnormalItemId': abnormalItemId,
        'AbnormalSeverity': abnormalSeverity,
        'AbnormalStatus': abnormalStatus,
        'ModifyDate': modifyDate,
      };
}

//    'abnormalItemId': 'YP002',
// 		'abnormalDescription': 'Size Mismatch',
// 		'monthlyDefectRate': 0.02
class QualityInspectionAbnormalItemInfo {
  RxString tag = ''.obs;

  String? abnormalItemId;
  String? abnormalDescription;
  double? monthlyDefectRate;

  QualityInspectionAbnormalItemInfo({
    this.abnormalItemId,
    this.abnormalDescription,
    this.monthlyDefectRate,
  });

  factory QualityInspectionAbnormalItemInfo.fromJson(dynamic json) =>
      QualityInspectionAbnormalItemInfo(
        abnormalItemId: json['ABNORMALITEMID'],
        abnormalDescription: json['ABNORMALDESCRIPTION'],
        monthlyDefectRate: json['MONTHLYDEFECTRATE'],
      );

  factory QualityInspectionAbnormalItemInfo.fromJsonIndex(
      dynamic json, int index) {
    var data = QualityInspectionAbnormalItemInfo(
      abnormalItemId: json[index]['ABNORMALITEMID'],
      abnormalDescription: json[index]['ABNORMALDESCRIPTION'],
      monthlyDefectRate:
          json[index]['MONTHLYDEFECTRATE'].toString().toDoubleTry(),
    );
    var saveTag = spGet('${data.abnormalItemId}-${userInfo?.number}');
    if (saveTag != null && saveTag.toString().isNotEmpty) {
      data.tag.value = saveTag;
    } else {
      data.tag.value = '${index + 1}';
    }
    return data;
  }

  String getDefectRate() => '${monthlyDefectRate.toShowString()}%';
}

//"creationTime": "2024-07-25 14:30:00",
// 	"abnormalItemId": "YP003",
// 	"abnormalRecordId": "YL003",
// 	"abnormalStatus": 1
class NewAbnormalRecordInfo {
  String? creationTime;
  String? abnormalItemId;
  String? abnormalRecordId;
  int? abnormalStatus;

  NewAbnormalRecordInfo({
    required this.creationTime,
    required this.abnormalItemId,
    required this.abnormalRecordId,
    required this.abnormalStatus,
  });

  factory NewAbnormalRecordInfo.fromJson(dynamic json) => NewAbnormalRecordInfo(
        creationTime: json['CREATIONTIME'],
        abnormalItemId: json['ABNORMALITEMID'],
        abnormalRecordId: json['ABNORMALRECORDID'],
        abnormalStatus: json['ABNORMALSTATUS'],
      );
}

enum AbnormalDegree {
  /// 轻微
  slight(1),

  ///严重
  serious(2);

  final int value;

  const AbnormalDegree(this.value);
}

//{
// 	"inspectionUnit": "针车2组",
// 	"abnormalRecords": [{
// 		"workOrderNo": "WO001",
// 		"lastModifyDate": "2024-05-20",
// 		"abnormalRecordsDetail": [{
// 			"abnormalDescription": "线头歪斜",
// 			"abnormalSeverity": 2,
// 			"abnormalStatus": 3,
// 			"firstInspector": "张三",
// 			"firstInspectionDate": "2025-05-01 20:30:29",
// 			"lastInspector": "张三",
// 			"lastInspectionDate": "2025-05-05 20:30:29"
// 		}]
// 	}]
// }

class QualityInspectionReportInfo {
  String? inspectionUnit;
  List<ReportOrderInfo>? abnormalRecords;

  QualityInspectionReportInfo({
    this.inspectionUnit,
    this.abnormalRecords,
  });

  QualityInspectionReportInfo.fromJson(dynamic json) {
    inspectionUnit = json['INSPECTIONUNIT'];
    abnormalRecords = [
      if (json['ABNORMALRECORDS'] != null)
        for (var j in json['ABNORMALRECORDS']) ReportOrderInfo.fromJson(j)
    ];
  }

  int getAbnormalTotalQty() => abnormalRecords!
      .map((v) => v.abnormalRecordsDetail!.length)
      .reduce((a, b) => a + b);

  int getReInspectionTotalQty() => abnormalRecords!
      .map((v) =>
          v.abnormalRecordsDetail!.where((v) => v.isLastInspector()).length)
      .reduce((a, b) => a + b);
}

class ReportOrderInfo {
  String? workOrderNo;
  String? lastModifyDate;
  List<ReportAbnormalRecordsDetailInfo>? abnormalRecordsDetail;

  ReportOrderInfo({
    this.workOrderNo,
    this.lastModifyDate,
    this.abnormalRecordsDetail,
  });

  ReportOrderInfo.fromJson(dynamic json) {
    workOrderNo = json['WORKORDERNO'];
    lastModifyDate = json['LASTMODIFYDATE'];
    abnormalRecordsDetail = [
      if (json['ABNORMALRECORDSDETAIL'] != null)
        for (var j in json['ABNORMALRECORDSDETAIL'])
          ReportAbnormalRecordsDetailInfo.fromJson(j)
    ];
  }
}

class ReportAbnormalRecordsDetailInfo {
  String? abnormalDescription;
  int? abnormalSeverity;
  int? abnormalStatus; //（1未质检、2质检中、3复检中、4质检完成)
  String? firstInspector;
  String? firstInspectionDate;
  String? lastInspector;
  String? lastInspectionDate;

  ReportAbnormalRecordsDetailInfo({
    this.abnormalDescription,
    this.abnormalSeverity,
    this.abnormalStatus,
    this.firstInspector,
    this.firstInspectionDate,
    this.lastInspector,
    this.lastInspectionDate,
  });

  factory ReportAbnormalRecordsDetailInfo.fromJson(dynamic json) {
    return ReportAbnormalRecordsDetailInfo(
      abnormalDescription: json['ABNORMALDESCRIPTION'],
      abnormalSeverity: json['ABNORMALSEVERITY'],
      abnormalStatus: json['ABNORMALSTATUS'],
      firstInspector: json['FIRSTINSPECTOR'],
      firstInspectionDate: json['FIRSTINSPECTIONDATE'],
      lastInspector: json['LASTINSPECTOR'],
      lastInspectionDate: json['LASTINSPECTIONDATE'],
    );
  }

  bool hasFirstInspector() =>
      firstInspector.isNullOrEmpty() && firstInspectionDate.isNullOrEmpty();

  bool hasLastInspector() =>
      lastInspector.isNullOrEmpty() && lastInspectionDate.isNullOrEmpty();

  bool isFirstInspector() => hasFirstInspector() && !hasLastInspector();

  bool isLastInspector() => hasFirstInspector() && hasLastInspector();

  String getAbnormalSeverityText() =>
      abnormalSeverity == AbnormalDegree.slight.value ? '轻微' : '严重';

  Color getAbnormalSeverityColor() =>
      abnormalSeverity == AbnormalDegree.slight.value
          ? Colors.orange
          : Colors.red;

  String getAbnormalStatusText() {
    switch (abnormalStatus) {
      case 1:
        return '未质检';
      case 2:
        return '质检中';
      case 3:
        return '复检中';
      case 4:
        return '质检完成';
      default:
        return '未知';
    }
  }

  Color getAbnormalStatusColor() {
    //1未质检、2质检中、3复检中、4质检完成
    switch (abnormalStatus) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
