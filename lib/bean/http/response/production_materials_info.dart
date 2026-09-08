import 'package:jd_flutter/utils/extension_util.dart';
// Company : "PAA"
// ProductionOrderNumber : "002002398159"
// DemandQuantity : "0.080"
// MaterialRequirementDate : "20240404"
// LatestBOMDemandQuantity : "0.000"
// Batch : "无"
// PlannedCompletionTime : "20240404"
// OrderDeliveryDate : "20240510"
// DeliveryQuantity : "0.000"
// SalesOrderNumber : "JZ2400096"
// MaterialCode : "800200818"
// NoPickQuantity : "0.080"
// Position : "裁断贴后内外边排衬"
// ProductionNum : "40.000"
// SpecificationAndModel : ""
// SubItemMaterialCode : "120126"
// SubUnits : "KG"
// SubItemSize : ""
// SubItemMaterialName : "白乳胶 2"
// BomVersion : "01"
// BomNo : "00000678"
// PlannedStartTime : "20240404"
// OrderType : "金帝大货生产订单"
// Size : "38"
// SupplementaryOrdersQuantity : "0.000"
// DispatchedWorkersNumber : "40.000"
// MaterialDescription : "鞋面-D13677-22B M, 38"
// OutsourcingProcess : ""

class ProductionMaterialsInfo {
  ProductionMaterialsInfo({
      this.company, 
      this.productionOrderNumber, 
      this.demandQuantity, 
      this.materialRequirementDate, 
      this.latestBOMDemandQuantity, 
      this.batch, 
      this.plannedCompletionTime, 
      this.orderDeliveryDate, 
      this.deliveryQuantity, 
      this.salesOrderNumber, 
      this.materialCode, 
      this.noPickQuantity, 
      this.position, 
      this.productionNum, 
      this.specificationAndModel, 
      this.subItemMaterialCode, 
      this.subUnits, 
      this.subItemSize, 
      this.subItemMaterialName, 
      this.bomVersion, 
      this.bomNo, 
      this.plannedStartTime, 
      this.orderType, 
      this.size, 
      this.supplementaryOrdersQuantity, 
      this.dispatchedWorkersNumber, 
      this.materialDescription, 
      this.outsourcingProcess,});

  ProductionMaterialsInfo.fromJson(dynamic json) {
    company = JsonParse.str(json['Company']);
    productionOrderNumber = JsonParse.str(json['ProductionOrderNumber']);
    demandQuantity = JsonParse.str(json['DemandQuantity']);
    materialRequirementDate = JsonParse.str(json['MaterialRequirementDate']);
    latestBOMDemandQuantity = JsonParse.str(json['LatestBOMDemandQuantity']);
    batch = JsonParse.str(json['Batch']);
    plannedCompletionTime = JsonParse.str(json['PlannedCompletionTime']);
    orderDeliveryDate = JsonParse.str(json['OrderDeliveryDate']);
    deliveryQuantity = JsonParse.str(json['DeliveryQuantity']);
    salesOrderNumber = JsonParse.str(json['SalesOrderNumber']);
    materialCode = JsonParse.str(json['MaterialCode']);
    noPickQuantity = JsonParse.str(json['NoPickQuantity']);
    position = JsonParse.str(json['Position']);
    productionNum = JsonParse.str(json['ProductionNum']);
    specificationAndModel = JsonParse.str(json['SpecificationAndModel']);
    subItemMaterialCode = JsonParse.str(json['SubItemMaterialCode']);
    subUnits = JsonParse.str(json['SubUnits']);
    subItemSize = JsonParse.str(json['SubItemSize']);
    subItemMaterialName = JsonParse.str(json['SubItemMaterialName']);
    bomVersion = JsonParse.str(json['BomVersion']);
    bomNo = JsonParse.str(json['BomNo']);
    plannedStartTime = JsonParse.str(json['PlannedStartTime']);
    orderType = JsonParse.str(json['OrderType']);
    size = JsonParse.str(json['Size']);
    supplementaryOrdersQuantity = JsonParse.str(json['SupplementaryOrdersQuantity']);
    dispatchedWorkersNumber = JsonParse.str(json['DispatchedWorkersNumber']);
    materialDescription = JsonParse.str(json['MaterialDescription']);
    outsourcingProcess = JsonParse.str(json['OutsourcingProcess']);
  }
  String? company;
  String? productionOrderNumber;
  String? demandQuantity;
  String? materialRequirementDate;
  String? latestBOMDemandQuantity;
  String? batch;
  String? plannedCompletionTime;
  String? orderDeliveryDate;
  String? deliveryQuantity;
  String? salesOrderNumber;
  String? materialCode;
  String? noPickQuantity;
  String? position;
  String? productionNum;
  String? specificationAndModel;
  String? subItemMaterialCode;
  String? subUnits;
  String? subItemSize;
  String? subItemMaterialName;
  String? bomVersion;
  String? bomNo;
  String? plannedStartTime;
  String? orderType;
  String? size;
  String? supplementaryOrdersQuantity;
  String? dispatchedWorkersNumber;
  String? materialDescription;
  String? outsourcingProcess;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Company'] = company;
    map['ProductionOrderNumber'] = productionOrderNumber;
    map['DemandQuantity'] = demandQuantity;
    map['MaterialRequirementDate'] = materialRequirementDate;
    map['LatestBOMDemandQuantity'] = latestBOMDemandQuantity;
    map['Batch'] = batch;
    map['PlannedCompletionTime'] = plannedCompletionTime;
    map['OrderDeliveryDate'] = orderDeliveryDate;
    map['DeliveryQuantity'] = deliveryQuantity;
    map['SalesOrderNumber'] = salesOrderNumber;
    map['MaterialCode'] = materialCode;
    map['NoPickQuantity'] = noPickQuantity;
    map['Position'] = position;
    map['ProductionNum'] = productionNum;
    map['SpecificationAndModel'] = specificationAndModel;
    map['SubItemMaterialCode'] = subItemMaterialCode;
    map['SubUnits'] = subUnits;
    map['SubItemSize'] = subItemSize;
    map['SubItemMaterialName'] = subItemMaterialName;
    map['BomVersion'] = bomVersion;
    map['BomNo'] = bomNo;
    map['PlannedStartTime'] = plannedStartTime;
    map['OrderType'] = orderType;
    map['Size'] = size;
    map['SupplementaryOrdersQuantity'] = supplementaryOrdersQuantity;
    map['DispatchedWorkersNumber'] = dispatchedWorkersNumber;
    map['MaterialDescription'] = materialDescription;
    map['OutsourcingProcess'] = outsourcingProcess;
    return map;
  }

}