<<<<<<< HEAD
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// OrderType : "Z001"
/// CompanyCode : "1000"
/// PurchaseVoucherNo : "4501200655"
/// PurchaseDocumentItemNumber : "00020"
/// PlanningLineNumber : "0010"
/// IsColorSeparation : ""
/// IsReturns : ""
/// SupplierNumber : "0000100760"
/// MaterialDescription : "0.22mm*1.5m白色JY28可特（针织布/100%涤纶）"
/// MaterialCode : "021800294"
/// MaterialDocumentNo : ""
/// MaterialDocumentNumberReversal : ""
/// MaterialVoucherYear : "0000"
/// MaterialVoucherAnnualReversal : "0000"
/// TaxCode : "J2"
/// Name1 : "晋江市三洋鞋材贸易有限公司"
/// CharacteristicValue : ""
/// SalesAndDistributionVoucherNumber : ""
/// FactoryNumber : "1001"
/// BaseQuantity : "369.447"
/// BasicUnit : "M"
/// BillDate : "2025-05-30"
/// TempreBillDate : "2025-05-29"
/// Biller : "650809"
/// BillTime : "16:18:41"
/// InspectionOrderNo : "330000498192"
/// InspectionLineNumber : "00003"
/// InspectionMethod : "全检"
/// InspectionQuantity : "27.778"
/// SamplingRatio : "0.0"
/// Coefficient : "13.3"
/// CommonUnits : "KG"
/// DeleteReason : ""
/// DeliAddress : "金旭"
/// ItemLineItem : "0000"
/// MaterialVoucherItem : ""
/// DetailIDReversal : "0000"
/// StorageQuantity : "0.0"
/// Location : ""
/// Location1 : ""
/// QualifiedQuantity : "27.778"
/// Remarks : "50kg"
/// Remarks1 : ""
/// SamplingQuantity : "27.778"
/// ShortCodesNumber : "0.0"
/// SourceOrderType : "送货单"
/// TemporaryNo : "320000492955"
/// TemporaryCollectionBankNo : "00030"
/// UnqualifiedQuantity : "0.0"
/// UnqualifiedReason : ""
/// DistributiveForm : "PDS25400367-02"
/// FullCheckFlag : ""
/// BatchIdentification : ""
/// FactoryType : ""
/// IsSelect : false
/// IsCodeRunningMaterial : ""
/// ColorSeparation : ""
/// IsPiece : ""
/// TrackNo : ""

class QualityInspectionInfo {
  QualityInspectionInfo({
      this.orderType,   //订单类型（采购）BSART
      this.companyCode,    //公司代码BUKRS
      this.purchaseVoucherNo,   //采购凭证号EBELN
      this.purchaseDocumentItemNumber,    //采购凭证的项目编号EBELP
      this.planningLineNumber,    //计划行编号ETENR
      this.isColorSeparation,   //是否分色ISCOSEP
      this.isReturns,   //是否已退货ISRETURNS
      this.supplierNumber,    //供应商编号LIFNR
      this.materialDescription,  //物料描述MAKTX
      this.materialCode,   //物料编码MATNR
      this.materialDocumentNo,   //物料凭证编号MBLNR
      this.materialDocumentNumberReversal,  //物料凭证编号冲销MBLNR_REV
      this.materialVoucherYear,    //物料凭证年度MJAHR
      this.materialVoucherAnnualReversal,   //物料凭证年度冲销MJAHR_REV
      this.taxCode,    //税码MWSKZ
      this.name1,  //供应商名称
      this.characteristicValue,  //特性值（季节性采购）SIZE1
      this.salesAndDistributionVoucherNumber,  //销售和分销凭证号VBELN
      this.factoryNumber,  //工厂编号WERKS
      this.baseQuantity,  //基本数量ZBASEQTY
      this.basicUnit,  //基本单位ZBASEUNIT
      this.billDate, //制单日期ZBILLDATE
      this.tempreBillDate,  //暂收日期ZBILLDATE_TEMPRE
      this.biller,  //制单人ZBILLER
      this.billTime,  //制单时间ZBILLTIME
      this.inspectionOrderNo, //检验单号ZCHECKBNO
      this.inspectionLineNumber, //检验单行号检验单行号ZCHECKBSEQ
      this.inspectionMethod, //检验方式ZCHECKMETHOD
      this.inspectionQuantity, //检验数量ZCHECKQTY
      this.samplingRatio, //抽检比例ZCHECKSCALE
      this.coefficient, //系数ZCOEFFICIENT
      this.commonUnits, //常用单位ZCOMMUNIT
      this.deleteReason, //删除原因ZDELETETEXT
      this.deliAddress, //送货地点ZDELIADDRESS
      this.itemLineItem,  //物料行项目ZEILE
      this.materialVoucherItem,  //物料凭证项目(逗号隔开)ZEILES
      this.detailIDReversal,  //明细id冲销ZEILE_REV
      this.storageQuantity, //入库数量ZINSTOCKQTY
      this.location, //货位ZLOCAL
      this.location1,  //货位ZLOCAL1
      this.qualifiedQuantity, //合格数量ZQUALIQTY
      this.remarks, //备注ZREMARK
      this.remarks1,  //备注ZREMARK_D2
      this.samplingQuantity, //抽检数量ZSCALEQTY
      this.shortCodesNumber, //短码数量ZSHORTCQTY
      this.sourceOrderType,  //源单类型ZSOURCETYPE
      this.temporaryNo, //暂收单号ZTEMPRENO
      this.temporaryCollectionBankNo, //暂收单行号ZTEMPRESEQ
      this.unqualifiedQuantity,  //不合格数量ZUNQUALIQTY
      this.unqualifiedReason, //不合格原因ZUNQUALITEXT
      this.distributiveForm,  //分配型体ZXT
      this.fullCheckFlag, //全检标志位，需要全检时为'X'ZZFSFLG
      this.batchIdentification,  //批次物料flag，可以分色时为'X'XCHAR
      this.factoryType,  //工厂型体ZZGCXT
      this.isCodeRunningMaterial, //是否是跑码物料ZISCLRUN
      this.colorSeparation,  //是否分色
      this.isPiece,  //是否  X启用
      this.trackNo,  //跟踪号

  });

  QualityInspectionInfo.fromJson(dynamic json) {
    orderType = json['OrderType'];
    companyCode = json['CompanyCode'];
    purchaseVoucherNo = json['PurchaseVoucherNo'];
    purchaseDocumentItemNumber = json['PurchaseDocumentItemNumber'];
    planningLineNumber = json['PlanningLineNumber'];
    isColorSeparation = json['IsColorSeparation'];
    isReturns = json['IsReturns'];
    supplierNumber = json['SupplierNumber'];
    materialDescription = json['MaterialDescription'];
    materialCode = json['MaterialCode'];
    materialDocumentNo = json['MaterialDocumentNo'];
    materialDocumentNumberReversal = json['MaterialDocumentNumberReversal'];
    materialVoucherYear = json['MaterialVoucherYear'];
    materialVoucherAnnualReversal = json['MaterialVoucherAnnualReversal'];
    taxCode = json['TaxCode'];
    name1 = json['Name1'];
    characteristicValue = json['CharacteristicValue'];
    salesAndDistributionVoucherNumber = json['SalesAndDistributionVoucherNumber'];
    factoryNumber = json['FactoryNumber'];
    baseQuantity = json['BaseQuantity'];
    basicUnit = json['BasicUnit'];
    billDate = json['BillDate'];
    tempreBillDate = json['TempreBillDate'];
    biller = json['Biller'];
    billTime = json['BillTime'];
    inspectionOrderNo = json['InspectionOrderNo'];
    inspectionLineNumber = json['InspectionLineNumber'];
    inspectionMethod = json['InspectionMethod'];
    inspectionQuantity = json['InspectionQuantity'];
    samplingRatio = json['SamplingRatio'];
    coefficient = json['Coefficient'];
    commonUnits = json['CommonUnits'];
    deleteReason = json['DeleteReason'];
    deliAddress = json['DeliAddress'];
    itemLineItem = json['ItemLineItem'];
    materialVoucherItem = json['MaterialVoucherItem'];
    detailIDReversal = json['DetailIDReversal'];
    storageQuantity = json['StorageQuantity'];
    location = json['Location'];
    location1 = json['Location1'];
    qualifiedQuantity = json['QualifiedQuantity'];
    remarks = json['Remarks'];
    remarks1 = json['Remarks1'];
    samplingQuantity = json['SamplingQuantity'];
    shortCodesNumber = json['ShortCodesNumber'];
    sourceOrderType = json['SourceOrderType'];
    temporaryNo = json['TemporaryNo'];
    temporaryCollectionBankNo = json['TemporaryCollectionBankNo'];
    unqualifiedQuantity = json['UnqualifiedQuantity'];
    unqualifiedReason = json['UnqualifiedReason'];
    distributiveForm = json['DistributiveForm'];
    fullCheckFlag = json['FullCheckFlag'];
    batchIdentification = json['BatchIdentification'];
    factoryType = json['FactoryType'];
    isCodeRunningMaterial = json['IsCodeRunningMaterial'];
    colorSeparation = json['ColorSeparation'];
    isPiece = json['IsPiece'];
    trackNo = json['TrackNo'];
  }
  String? orderType;
  String? companyCode;
  String? purchaseVoucherNo;
  String? purchaseDocumentItemNumber;
  String? planningLineNumber;
  String? isColorSeparation;
  String? isReturns;
  String? supplierNumber;
  String? materialDescription;
  String? materialCode;
  String? materialDocumentNo;
  String? materialDocumentNumberReversal;
  String? materialVoucherYear;
  String? materialVoucherAnnualReversal;
  String? taxCode;
  String? name1;
  String? characteristicValue;
  String? salesAndDistributionVoucherNumber;
  String? factoryNumber;
  String? baseQuantity;
  String? basicUnit;
  String? billDate;
  String? tempreBillDate;
  String? biller;
  String? billTime;
  String? inspectionOrderNo;
  String? inspectionLineNumber;
  String? inspectionMethod;
  String? inspectionQuantity;
  String? samplingRatio;
  String? coefficient;
  String? commonUnits;
  String? deleteReason;
  String? deliAddress;
  String? itemLineItem;
  String? materialVoucherItem;
  String? detailIDReversal;
  String? storageQuantity;
  String? location;
  String? location1;
  String? qualifiedQuantity;
  String? remarks;
  String? remarks1;
  String? samplingQuantity;
  String? shortCodesNumber;
  String? sourceOrderType;
  String? temporaryNo;
  String? temporaryCollectionBankNo;
  String? unqualifiedQuantity;
  String? unqualifiedReason;
  String? distributiveForm;
  String? fullCheckFlag;
  String? batchIdentification;
  String? factoryType;
  String? isCodeRunningMaterial;
  String? colorSeparation;
  String? isPiece;
  String? trackNo;
  RxBool isSelected = false.obs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['OrderType'] = orderType;
    map['CompanyCode'] = companyCode;
    map['PurchaseVoucherNo'] = purchaseVoucherNo;
    map['PurchaseDocumentItemNumber'] = purchaseDocumentItemNumber;
    map['PlanningLineNumber'] = planningLineNumber;
    map['IsColorSeparation'] = isColorSeparation;
    map['IsReturns'] = isReturns;
    map['SupplierNumber'] = supplierNumber;
    map['MaterialDescription'] = materialDescription;
    map['MaterialCode'] = materialCode;
    map['MaterialDocumentNo'] = materialDocumentNo;
    map['MaterialDocumentNumberReversal'] = materialDocumentNumberReversal;
    map['MaterialVoucherYear'] = materialVoucherYear;
    map['MaterialVoucherAnnualReversal'] = materialVoucherAnnualReversal;
    map['TaxCode'] = taxCode;
    map['Name1'] = name1;
    map['CharacteristicValue'] = characteristicValue;
    map['SalesAndDistributionVoucherNumber'] = salesAndDistributionVoucherNumber;
    map['FactoryNumber'] = factoryNumber;
    map['BaseQuantity'] = baseQuantity;
    map['BasicUnit'] = basicUnit;
    map['BillDate'] = billDate;
    map['TempreBillDate'] = tempreBillDate;
    map['Biller'] = biller;
    map['BillTime'] = billTime;
    map['InspectionOrderNo'] = inspectionOrderNo;
    map['InspectionLineNumber'] = inspectionLineNumber;
    map['InspectionMethod'] = inspectionMethod;
    map['InspectionQuantity'] = inspectionQuantity;
    map['SamplingRatio'] = samplingRatio;
    map['Coefficient'] = coefficient;
    map['CommonUnits'] = commonUnits;
    map['DeleteReason'] = deleteReason;
    map['DeliAddress'] = deliAddress;
    map['ItemLineItem'] = itemLineItem;
    map['MaterialVoucherItem'] = materialVoucherItem;
    map['DetailIDReversal'] = detailIDReversal;
    map['StorageQuantity'] = storageQuantity;
    map['Location'] = location;
    map['Location1'] = location1;
    map['QualifiedQuantity'] = qualifiedQuantity;
    map['Remarks'] = remarks;
    map['Remarks1'] = remarks1;
    map['SamplingQuantity'] = samplingQuantity;
    map['ShortCodesNumber'] = shortCodesNumber;
    map['SourceOrderType'] = sourceOrderType;
    map['TemporaryNo'] = temporaryNo;
    map['TemporaryCollectionBankNo'] = temporaryCollectionBankNo;
    map['UnqualifiedQuantity'] = unqualifiedQuantity;
    map['UnqualifiedReason'] = unqualifiedReason;
    map['DistributiveForm'] = distributiveForm;
    map['FullCheckFlag'] = fullCheckFlag;
    map['BatchIdentification'] = batchIdentification;
    map['FactoryType'] = factoryType;
    map['IsCodeRunningMaterial'] = isCodeRunningMaterial;
    map['ColorSeparation'] = colorSeparation;
    map['IsPiece'] = isPiece;
    map['TrackNo'] = trackNo;
    return map;
  }

}
=======
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
  int? abnormalStatus;
  String? modifyDate;

  QualityInspectionAbnormalRecordInfo({
    this.abnormalRecordId,
    this.abnormalItemId,
    this.abnormalStatus,
    this.modifyDate,
  });

  factory QualityInspectionAbnormalRecordInfo.fromJson(dynamic json) =>
      QualityInspectionAbnormalRecordInfo(
        abnormalRecordId: json['ABNORMALRECORDID'],
        abnormalItemId: json['ABNORMALITEMID'],
        abnormalStatus: json['ABNORMALSTATUS'],
        modifyDate: json['MODIFYDATE'],
      );

  Map<String, dynamic> toJson() => {
        'isSelect': isSelect.value,
        'AbnormalRecordId': abnormalRecordId,
        'AbnormalItemId': abnormalItemId,
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
    var saveTag = spGet('QI-${data.abnormalItemId}-${userInfo?.number}');
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
>>>>>>> origin/master
