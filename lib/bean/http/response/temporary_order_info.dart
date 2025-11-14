//{
//   "CompanyCode": "金帝集团股份有限公司",
//   "FactoryName": "金帝贸易仓库",
//   "TemporaryNo": "320000000581",
//   "SupplierName": "浙江冠亚鞋业有限公司",
//   "BillDate": "2025-04-24",
//   "Biller": "013600_潘卓旭",
//   "Remark": "",
//   "StorageLocationName": "面料仓",
//   "MaterialCode": "10010105345",
//   "MaterialName": "40#黑色锦纶线S",
//   "ColorSeparation": "",
//   "BaseUnit": "米",
//   "CommUnit": "个",
//   "Coefficient": "1700.0",
//   "DeleteReason": "",
//   "DetailRemark": "",
//   "Model": "D13677-22B M",
//   "DistributionType": "XXXX",
//   "KunnrLast": "",
//   "TemporarySize": [
//     {
//       "Size": "",
//       "Qty": "0",
//       "BaseQty": "0"
//     }
//   ]
// },

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class TemporaryOrderInfo {
  String? companyCode;
  String? factoryName;
  String? temporaryNo;
  String? supplierName;
  String? billDate;
  String? biller;
  String? remark;
  String? storageLocationName;
  String? materialCode;
  String? materialName;
  String? colorSeparation;
  String? baseUnit;
  String? commUnit;
  String? coefficient;
  String? deleteReason;
  String? detailRemark;
  String? model;
  String? distributionType;
  String? finalCustomer;
  List<TemporarySize>? temporarySize;

  TemporaryOrderInfo(
      {this.companyCode,
      this.factoryName,
      this.temporaryNo,
      this.supplierName,
      this.billDate,
      this.biller,
      this.remark,
      this.storageLocationName,
      this.materialCode,
      this.materialName,
      this.colorSeparation,
      this.baseUnit,
      this.commUnit,
      this.coefficient,
      this.deleteReason,
      this.detailRemark,
      this.model,
      this.distributionType,
      this.finalCustomer,
      this.temporarySize});

  TemporaryOrderInfo.fromJson(dynamic json) {
    companyCode = json['CompanyCode'];
    factoryName = json['FactoryName'];
    temporaryNo = json['TemporaryNo'];
    supplierName = json['SupplierName'];
    billDate = json['BillDate'];
    biller = json['Biller'];
    remark = json['Remark'];
    storageLocationName = json['StorageLocationName'];
    materialCode = json['MaterialCode'];
    materialName = json['MaterialName'];
    colorSeparation = json['ColorSeparation'];
    baseUnit = json['BaseUnit'];
    commUnit = json['CommUnit'];
    coefficient = json['Coefficient'];
    deleteReason = json['DeleteReason'];
    detailRemark = json['DetailRemark'];
    model = json['Model'];
    distributionType = json['DistributionType'];
    finalCustomer = json['KunnrLast'];
    if (json['TemporarySize'] != null) {
      temporarySize = [];
      json['TemporarySize'].forEach((v) {
        temporarySize?.add(TemporarySize.fromJson(v));
      });
    }
  }

  String temporaryQty() {
    var sum = 0.0;
    var baseSum = 0.0;
    temporarySize?.forEach((v) {
      sum = v.qty.toDoubleTry().add(sum);
      baseSum = v.baseQty.toDoubleTry().add(baseSum);
    });
    return baseUnit == commUnit
        ? '${sum.toShowString()} $commUnit'
        : '${sum.toShowString()} $commUnit / ${baseSum.toShowString()} $baseUnit';
  }
}

//{
//   "Size": "",
//   "Qty": "0",
//   "BaseQty": "0"
// }
class TemporarySize {
  String? size;
  String? qty;
  String? baseQty;

  TemporarySize({
    this.size,
    this.qty,
    this.baseQty,
  });

  TemporarySize.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    baseQty = json['BaseQty'];
  }
}

//{
// "CompanyName": "金帝集团股份有限公司",
// "TemporaryNumber": "320000000581",
// "TemporaryDate": "2025-04-24",
// "SourceType": "送货单",
// "SupplierName": "浙江冠亚鞋业有限公司",
// "DeliveryNumber": "310000001080",
// "ProducerNumber": "013600",
// "ProducerName": "潘卓旭",
// "ProducerDate": "2025-04-24 14:03:46",
// "Reviewer": "",
// "AuditDate": "0000-00-00 00:00:00",
// "Reviser": "",
// "ModificationDate": "0000-00-00 00:00:00",
// "CompanyNumber": "1000",
// "SupplierNumber": "0000500289",
// "FactoryNumber": "1098",
// "StorageLocationNumber": "1001",
// "StorageLocationName": "面料仓",
// "Remarks": "",
// }
class TemporaryOrderDetailInfo {
  String? companyName;
  String? temporaryNumber;
  String? temporaryDate;
  String? sourceType;
  String? supplierName;
  String? deliveryNumber;
  String? producerNumber;
  String? producerName;
  String? producerDate;
  String? reviewer;
  String? auditDate;
  String? reviser;
  String? modificationDate;
  String? companyNumber;
  String? supplierNumber;
  String? factoryNumber;
  String? storageLocationNumber;
  String? storageLocationName;
  String? remarks;
  List<TemporaryOrderDetailReceiptInfo>? receipt;


  TemporaryOrderDetailInfo({
    this.companyName,
    this.temporaryNumber,
    this.temporaryDate,
    this.sourceType,
    this.supplierName,
    this.deliveryNumber,
    this.producerNumber,
    this.producerName,
    this.producerDate,
    this.reviewer,
    this.auditDate,
    this.reviser,
    this.modificationDate,
    this.companyNumber,
    this.supplierNumber,
    this.factoryNumber,
    this.storageLocationNumber,
    this.storageLocationName,
    this.remarks,
    this.receipt,
  });

  TemporaryOrderDetailInfo.fromJson(dynamic json) {
    companyName = json['CompanyName'];
    temporaryNumber = json['TemporaryNumber'];
    temporaryDate = json['TemporaryDate'];
    sourceType = json['SourceType'];
    supplierName = json['SupplierName'];
    deliveryNumber = json['DeliveryNumber'];
    producerNumber = json['ProducerNumber'];
    producerName = json['ProducerName'];
    producerDate = json['ProducerDate'];
    reviewer = json['Reviewer'];
    auditDate = json['AuditDate'];
    reviser = json['Reviser'];
    modificationDate = json['ModificationDate'];
    companyNumber = json['CompanyNumber'];
    supplierNumber = json['SupplierNumber'];
    factoryNumber = json['FactoryNumber'];
    storageLocationNumber = json['StorageLocationNumber'];
    storageLocationName = json['StorageLocationName'];
    remarks = json['Remarks'];
    receipt = [];
    if (json['Receipt'] != null) {
      json['Receipt'].forEach((v) {
        receipt?.add(TemporaryOrderDetailReceiptInfo.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyName'] = companyName;
    map['TemporaryNumber'] = temporaryNumber;
    map['TemporaryDate'] = temporaryDate;
    map['SourceType'] = sourceType;
    map['SupplierName'] = supplierName;
    map['DeliveryNumber'] = deliveryNumber;
    map['ProducerNumber'] = producerNumber;
    map['ProducerName'] = producerName;
    map['ProducerDate'] = producerDate;
    map['Reviewer'] = reviewer;
    map['AuditDate'] = auditDate;
    map['Reviser'] = reviser;
    map['ModificationDate'] = modificationDate;
    map['CompanyNumber'] = companyNumber;
    map['SupplierNumber'] = supplierNumber;
    map['FactoryNumber'] = factoryNumber;
    map['StorageLocationNumber'] = storageLocationNumber;
    map['StorageLocationName'] = storageLocationName;
    map['Remarks'] = remarks;
    if (receipt != null) {
      map['Receipt'] = receipt?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  bool isSelectedAll() => receipt!
      .where((v) => (v.quantityTemporarilyReceived ?? 0) > 0)
      .every((v) => v.isSelected.value);

  selectedAll(bool select) {
    for (var v in receipt!) {
      v.isSelected.value = select;
    }
  }
}

//{
//   "PurchaseType": "大货采购订单",
//   "ContractNo": "4510010321",
//   "PurchaseOrderLineNumber": "00230",
//   "PlanningLineNumber": "0010",
//   "TemporaryLineNumber": "00010",
//   "ProductionNumber": "MZ2400014",
//   "FactoryModel": "D13677-22B M",
//   "DistributiveModel": "XXXX",
//   "DeliveryDate": "2025-04-24",
//   "MaterialCode": "10010105345",
//   "MaterialName": "40#黑色锦纶线S",
//   "MainMaterialCode": "",
//   "MainMaterialName": "",
//   "Specification": "40#",
//   "QuantityTemporarilyReceived": 0.0,
//   "Size": "",
//   "InspectionQuantity": 0.0,
//   "QualifiedQuantity": 0.0,
//   "UnqualifiedQuantity": 0.0,
//   "EnterWarehouseQuantity": 0.0,
//   "Remarks": "",
//   "DeliveryOrderLineNumber": "00010",
//   "BasicQuantity": 0.0,
//   "Coefficient": 1700.0,
//   "CommonUnits": "个",
//   "BasicUnits": "米",
//   "FullInspection": "",
//   "CanColorSeparation": "",
//   "MissingQuantity": 0.0,
//   "HasLengthCheckData": "",
//   "ColorSeparation": "",
//   "Result1": "02"
// }
class TemporaryOrderDetailReceiptInfo {
  RxBool isSelected = false.obs;

  String? purchaseType;
  String? contractNo;
  String? purchaseOrderLineNumber;
  String? planningLineNumber;
  String? temporaryLineNumber;
  String? productionNumber;
  String? factoryModel;
  String? distributiveModel;
  String? deliveryDate;
  String? materialCode;
  String? materialName;
  String? mainMaterialCode;
  String? mainMaterialName;
  String? specification;
  double? quantityTemporarilyReceived;
  String? size;
  double? inspectionQuantity;
  double? qualifiedQuantity;
  double? unqualifiedQuantity;
  double? enterWarehouseQuantity;
  String? remarks;
  String? deliveryOrderLineNumber;
  double? basicQuantity;
  double? coefficient;
  String? commonUnits;
  String? basicUnits;
  String? fullInspection;
  String? canColorSeparation;
  double? missingQuantity;
  String? hasLengthCheckData;
  String? colorSeparation;
  String? result1;
  String? barCode;
  double? samplingQuantity;

  TemporaryOrderDetailReceiptInfo({
    this.purchaseType,
    this.contractNo,
    this.purchaseOrderLineNumber,
    this.planningLineNumber,
    this.temporaryLineNumber,
    this.productionNumber,
    this.factoryModel,
    this.distributiveModel,
    this.deliveryDate,
    this.materialCode,
    this.materialName,
    this.mainMaterialCode,
    this.mainMaterialName,
    this.specification,
    this.quantityTemporarilyReceived,
    this.size,
    this.inspectionQuantity,
    this.qualifiedQuantity,
    this.unqualifiedQuantity,
    this.enterWarehouseQuantity,
    this.remarks,
    this.deliveryOrderLineNumber,
    this.basicQuantity,
    this.coefficient,
    this.commonUnits,
    this.basicUnits,
    this.fullInspection,
    this.canColorSeparation,
    this.missingQuantity,
    this.hasLengthCheckData,
    this.colorSeparation,
    this.result1,
    this.barCode,
    this.samplingQuantity,
  });

  TemporaryOrderDetailReceiptInfo.fromJson(dynamic json) {
    purchaseType = json['PurchaseType'];
    contractNo = json['ContractNo'];
    purchaseOrderLineNumber = json['PurchaseOrderLineNumber'];
    planningLineNumber = json['PlanningLineNumber'];
    temporaryLineNumber = json['TemporaryLineNumber'];
    productionNumber = json['ProductionNumber'];
    factoryModel = json['FactoryModel'];
    distributiveModel = json['DistributiveModel'];
    deliveryDate = json['DeliveryDate'];
    materialCode = json['MaterialCode'];
    materialName = json['MaterialName'];
    mainMaterialCode = json['MainMaterialCode'];
    mainMaterialName = json['MainMaterialName'];
    specification = json['Specification'];
    quantityTemporarilyReceived = json['QuantityTemporarilyReceived'];
    size = json['Size'];
    inspectionQuantity = json['InspectionQuantity'];
    qualifiedQuantity = json['QualifiedQuantity'];
    unqualifiedQuantity = json['UnqualifiedQuantity'];
    enterWarehouseQuantity = json['EnterWarehouseQuantity'];
    remarks = json['Remarks'];
    deliveryOrderLineNumber = json['DeliveryOrderLineNumber'];
    basicQuantity = json['BasicQuantity'];
    coefficient = json['Coefficient'];
    commonUnits = json['CommonUnits'];
    basicUnits = json['BasicUnits'];
    fullInspection = json['FullInspection'];
    canColorSeparation = json['CanColorSeparation'];
    missingQuantity = json['MissingQuantity'];
    hasLengthCheckData = json['HasLengthCheckData'];
    colorSeparation = json['ColorSeparation'];
    result1 = json['Result1'];
    barCode = json['BQID_Org'];
    samplingQuantity = json['SamplingQuantity'];
    isSelected.value = json['isSelected']??false;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PurchaseType'] = purchaseType;
    map['ContractNo'] = contractNo;
    map['PurchaseOrderLineNumber'] = purchaseOrderLineNumber;
    map['PlanningLineNumber'] = planningLineNumber;
    map['TemporaryLineNumber'] = temporaryLineNumber;
    map['ProductionNumber'] = productionNumber;
    map['FactoryModel'] = factoryModel;
    map['DistributiveModel'] = distributiveModel;
    map['DeliveryDate'] = deliveryDate;
    map['MaterialCode'] = materialCode;
    map['MaterialName'] = materialName;
    map['MainMaterialCode'] = mainMaterialCode;
    map['MainMaterialName'] = mainMaterialName;
    map['Specification'] = specification;
    map['QuantityTemporarilyReceived'] = quantityTemporarilyReceived;
    map['Size'] = size;
    map['InspectionQuantity'] = inspectionQuantity;
    map['QualifiedQuantity'] = qualifiedQuantity;
    map['UnqualifiedQuantity'] = unqualifiedQuantity;
    map['EnterWarehouseQuantity'] = enterWarehouseQuantity;
    map['Remarks'] = remarks;
    map['DeliveryOrderLineNumber'] = deliveryOrderLineNumber;
    map['BasicQuantity'] = basicQuantity;
    map['Coefficient'] = coefficient;
    map['CommonUnits'] = commonUnits;
    map['BasicUnits'] = basicUnits;
    map['FullInspection'] = fullInspection;
    map['CanColorSeparation'] = canColorSeparation;
    map['MissingQuantity'] = missingQuantity;
    map['HasLengthCheckData'] = hasLengthCheckData;
    map['ColorSeparation'] = colorSeparation;
    map['Result1'] = result1;
    map['BQID_Org'] = barCode;
    map['SamplingQuantity'] = samplingQuantity;
    map['isSelected'] = isSelected.value;

    return map;
  }

  String getTestStateText() {
    switch (result1) {
      case "01":
        return 'temporary_order_test_state_incomplete'.tr;
      case "02":
        return 'temporary_order_test_state_not_applied'.tr;
      case "03":
        return 'temporary_order_test_state_pass_through'.tr;
      case "04":
        return 'temporary_order_test_state_acceptable'.tr;
      case "05":
        return 'temporary_order_test_state_refuse'.tr;
      default:
        return 'temporary_order_test_state_cancel'.tr;
    }
  }

  Color getTestStateColor() {
    switch (result1) {
      case "01":
        return Colors.orange;
      case "02":
        return Colors.grey;
      case "03":
        return Colors.green;
      case "04":
        return Colors.blue;
      case "05":
        return Colors.red;
      default:
        return Colors.black87;
    }
  }
}
class TestStandardsInfo{
 String? testStandardsNumber;
 String? testStandardsName;

 TestStandardsInfo({this.testStandardsNumber, this.testStandardsName});

 TestStandardsInfo.fromJson(dynamic json) {
    testStandardsNumber = json['NONUMBER'];
    testStandardsName = json['NONAME'];
  }
  @override
  String toString() {
   return '$testStandardsNumber - $testStandardsName';
  }
}