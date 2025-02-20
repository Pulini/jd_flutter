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
    company = json['Company'];
    productionOrderNumber = json['ProductionOrderNumber'];
    demandQuantity = json['DemandQuantity'];
    materialRequirementDate = json['MaterialRequirementDate'];
    latestBOMDemandQuantity = json['LatestBOMDemandQuantity'];
    batch = json['Batch'];
    plannedCompletionTime = json['PlannedCompletionTime'];
    orderDeliveryDate = json['OrderDeliveryDate'];
    deliveryQuantity = json['DeliveryQuantity'];
    salesOrderNumber = json['SalesOrderNumber'];
    materialCode = json['MaterialCode'];
    noPickQuantity = json['NoPickQuantity'];
    position = json['Position'];
    productionNum = json['ProductionNum'];
    specificationAndModel = json['SpecificationAndModel'];
    subItemMaterialCode = json['SubItemMaterialCode'];
    subUnits = json['SubUnits'];
    subItemSize = json['SubItemSize'];
    subItemMaterialName = json['SubItemMaterialName'];
    bomVersion = json['BomVersion'];
    bomNo = json['BomNo'];
    plannedStartTime = json['PlannedStartTime'];
    orderType = json['OrderType'];
    size = json['Size'];
    supplementaryOrdersQuantity = json['SupplementaryOrdersQuantity'];
    dispatchedWorkersNumber = json['DispatchedWorkersNumber'];
    materialDescription = json['MaterialDescription'];
    outsourcingProcess = json['OutsourcingProcess'];
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