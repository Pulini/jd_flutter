abstract class PickerItem {
  String pickerName();

  String pickerId();

  String toShow();

  @override
  String toString() {
    return toShow();
  }
}

abstract class LinkPickerItem extends PickerItem {
  List<PickerItem> subList();
}

class PickerSapSupplier extends PickerItem {
  PickerSapSupplier({
    required this.name,
    required this.supplierNumber,
  });

  PickerSapSupplier.fromJson(dynamic json) {
    name = json['Name'];
    supplierNumber = json['SAPSupplierNumber'];
  }

  String? name;
  String? supplierNumber;

  @override
  String pickerId() {
    return supplierNumber ?? '';
  }

  @override
  String pickerName() {
    return name?.trim() ?? '';
  }

  @override
  String toShow() {
    return '($supplierNumber)-$name';
  }
}

class PickerSapCompany extends PickerItem {
  PickerSapCompany({
    required this.company,
  });

  PickerSapCompany.fromJson(dynamic json) {
    company = json['FactoryArea'];
  }

  String? company;

  @override
  String pickerId() {
    return company ?? '';
  }

  @override
  String pickerName() {
    return company ?? '';
  }

  @override
  String toShow() {
    return company ?? '';
  }
}

class PickerSapFactory extends PickerItem {
  PickerSapFactory({
    required this.name,
    required this.number,
  });

  PickerSapFactory.fromJson(dynamic json) {
    name = json['Name'];
    number = json['SAPNumber'];
  }

  String? name;
  int? number;

  @override
  String pickerId() {
    return number == null || number == 0 ? '' : number.toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return name ?? '';
  }
}

class PickerSapWorkCenter extends PickerItem {
  PickerSapWorkCenter({
    required this.name,
    required this.number,
  });

  PickerSapWorkCenter.fromJson(dynamic json) {
    name = json['Name'];
    number = json['SAPNumber'];
  }

  String? name;
  String? number;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerSapDepartment extends PickerItem {
  PickerSapDepartment({
    required this.name,
    required this.departmentId,
    required this.number,
  });

  PickerSapDepartment.fromJson(dynamic json) {
    name = json['Name'];
    departmentId = json['DepartmentID'];
    number = json['SAPNumber'];
  }

  String? name;
  int? departmentId;
  String? number;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerMesWorkShop extends PickerItem {
  PickerMesWorkShop({
    required this.name,
    required this.number,
    required this.processFlowId,
  });

  PickerMesWorkShop.fromJson(dynamic json) {
    name = json['Name'];
    number = json['Number'];
    processFlowId = json['ProcessFlowID'];
  }

  String? name;
  String? number;
  int? processFlowId;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerMesDepartment extends PickerItem {
  PickerMesDepartment({
    required this.name,
    required this.number,
    required this.departmentId,
  });

  PickerMesDepartment.fromJson(dynamic json) {
    name = json['Name'];
    departmentId = json['DepartmentID'];
    number = json['SAPNumber'];
  }

  String? name;
  String? number;
  int? departmentId;

  @override
  String pickerId() {
    return (departmentId ?? 0).toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerMesOrganization extends PickerItem {
  PickerMesOrganization({
    required this.itemId,
    required this.code,
    required this.name,
    required this.number,
    required this.adminOrganizeId,
  });

  PickerMesOrganization.fromJson(dynamic json) {
    itemId = json['ItemID'];
    code = json['Code'];
    name = json['Name'];
    number = json['Number'];
    adminOrganizeId = json['AdminOrganizeID'];
  }

  String? name;
  String? number;
  int? adminOrganizeId;
  int? itemId;
  String? code;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerSapProcessFlow extends PickerItem {
  PickerSapProcessFlow({
    required this.name,
    required this.number,
  });

  PickerSapProcessFlow.fromJson(dynamic json) {
    name = json['Name'];
    number = json['SAPNumber'];
  }

  String? name;
  String? number;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerMesProcessFlow extends PickerItem {
  PickerMesProcessFlow({
    required this.name,
    required this.processFlowId,
  });

  PickerMesProcessFlow.fromJson(dynamic json) {
    name = json['ProcessFlowName'];
    processFlowId = json['ProcessFlowID'];
  }

  String? name;
  int? processFlowId;

  @override
  String pickerId() {
    return (processFlowId ?? 0).toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return name ?? '';
  }
}

class PickerSapMachine extends PickerItem {
  PickerSapMachine({
    required this.id,
    required this.number,
    required this.name,
    required this.sapNumber,
    required this.sapCostCenterNumber,
  });

  PickerSapMachine.fromJson(dynamic json) {
    id = json['ID'];
    number = json['FNumber'];
    name = json['FName'];
    sapNumber = json['SAPNumber'];
    sapCostCenterNumber = json['FSAPCostCenterNumber'];
  }

  int? id;
  String? number;
  String? name;
  String? sapNumber;
  String? sapCostCenterNumber;

  @override
  String pickerId() {
    return id.toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerSapWorkCenterNew extends PickerItem {
  PickerSapWorkCenterNew({
    required this.name,
    required this.number,
  });

  PickerSapWorkCenterNew.fromJson(dynamic json) {
    name = json['Name'];
    number = json['SAPNumber'];
  }

  String? name;
  String? number;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return '($number)-$name';
  }
}

class PickerSapGroup extends PickerItem {
  PickerSapGroup({
    required this.name,
    required this.itemId,
  });

  PickerSapGroup.fromJson(dynamic json) {
    name = json['Name'];
    itemId = json['ItemID'];
  }

  String? name;
  int? itemId;

  @override
  String pickerId() {
    return (itemId ?? 0).toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return name ?? '';
  }
}

class PickerSapFactoryAndWarehouse extends LinkPickerItem {
  PickerSapFactoryAndWarehouse({
    required this.name,
    required this.number,
    required this.warehouseList,
  });

  PickerSapFactoryAndWarehouse.fromJson(dynamic json) {
    name = json['SapFactoryName'];
    number = json['SapFactoryNumber'];
    if (json['StockList'] != null) {
      warehouseList = [];
      json['StockList'].forEach((v) {
        warehouseList?.add(PickerSapWarehouse.fromJson(v));
      });
    }
  }

  String? name;
  String? number;
  List<PickerSapWarehouse>? warehouseList;

  @override
  String pickerId() {
    return number ?? '';
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  List<PickerItem> subList() {
    return warehouseList ?? [];
  }

  @override
  String toShow() {
    return name??'';
  }
}

class PickerSapWarehouse extends PickerItem {
  PickerSapWarehouse({
    required this.warehouseName,
    required this.warehouseNumber,
    required this.warehouseId,
  });

  PickerSapWarehouse.fromJson(dynamic json) {
    warehouseName = json['SAPStockName'];
    warehouseId = json['StockID'];
    warehouseNumber = json['SAPStockNumber'];
  }

  String? warehouseName;
  String? warehouseNumber;
  String? warehouseId;

  @override
  String pickerId() {
    return warehouseNumber ?? '';
  }

  @override
  String pickerName() {
    return warehouseName ?? '';
  }

  @override
  String toShow() {
    return '$warehouseName($warehouseNumber)';
  }
}

class PickerMesProductionReportType extends PickerItem {
  PickerMesProductionReportType({
    required this.itemID,
    required this.itemName,
  });

  PickerMesProductionReportType.fromJson(dynamic json) {
    itemID = json['ItemID'];
    itemName = json['ItemName'];
  }

  int? itemID;
  String? itemName;

  @override
  String pickerId() {
    return (itemID ?? 0).toString();
  }

  @override
  String pickerName() {
    return itemName ?? '';
  }

  @override
  String toShow() {
    return itemName ?? '';
  }
}

class PickerMesMoldingPackArea extends PickerItem {
  PickerMesMoldingPackArea({
    required this.id,
    required this.name,
  });

  PickerMesMoldingPackArea.fromJson(dynamic json) {
    id = json['InterID'];
    name = json['Name'];
  }

  int? id;
  String? name;
  bool isChecked = false;

  @override
  String pickerId() {
    return (id ?? 0).toString();
  }

  @override
  String pickerName() {
    return name?.trim() ?? '';
  }

  @override
  String toShow() {
    return name ?? '';
  }
}

class PickerSapWarehouseLocation extends PickerItem {
  PickerSapWarehouseLocation({
    required this.location,
    required this.noUsedNum,
  });

  PickerSapWarehouseLocation.fromJson(dynamic json) {
    location = json['Location'];
    noUsedNum = json['NoUsedNum'];
  }

  String? location;
  double? noUsedNum;

  @override
  String pickerId() {
    return location ?? '';
  }

  @override
  String pickerName() {
    return '$location - 剩余$noUsedNum';
  }

  @override
  String toShow() {
    return '$location - 剩余$noUsedNum';
  }
}

class PickerMesGroup extends PickerItem {
  PickerMesGroup({
    required this.departmentID,
    required this.departmentNumber,
    required this.departmentName,
  });

  PickerMesGroup.fromJson(dynamic json) {
    departmentID = json['DepartmentID'];
    departmentNumber = json['DepartmentNumber'];
    departmentName = json['DepartmentName'];
  }

  int? departmentID;
  String? departmentNumber;
  String? departmentName;

  @override
  String pickerId() {
    return departmentID.toString();
  }

  @override
  String pickerName() {
    return departmentName ?? '';
  }

  @override
  String toShow() {
    return '($departmentNumber)-$departmentName';
  }
}

class MesStockInfo extends LinkPickerItem {
  MesStockInfo({
    required this.itemID,
    required this.name,
    required this.stockList,
  });

  MesStockInfo.fromJson(dynamic json) {
    name = json['Name'];
    itemID = json['ItemID'];
    if (json['EntryList'] != null) {
      stockList = [];
      json['EntryList'].forEach((v) {
        stockList?.add(StockItem.fromJson(v));
      });
    }
  }

  int? itemID;
  String? name;
  List<StockItem>? stockList;

  @override
  String pickerId() {
    return (itemID ?? -1).toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  List<PickerItem> subList() {
    return stockList ?? [];
  }

  @override
  String toShow() {
    return name ?? '';
  }
}

class StockItem extends PickerItem {
  StockItem({
    required this.itemID,
    required this.name,
  });

  StockItem.fromJson(dynamic json) {
    itemID = json['ItemID'];
    name = json['Name'];
  }

  int? itemID;
  String? name;

  @override
  String pickerId() {
    return (itemID ?? -1).toString();
  }

  @override
  String pickerName() {
    return name ?? '';
  }

  @override
  String toShow() {
    return name ?? '';
  }
}

class OrderStockItem extends PickerItem {
  OrderStockItem({
    required this.factoryID,
    required this.stockName,
    required this.stockID,
  });

  OrderStockItem.fromJson(dynamic json) {
    factoryID = json['FactoryID'];
    stockName = json['StockName'];
    stockID = json['StockID'];
  }

  String? factoryID;
  String? stockName;
  int? stockID;

  @override
  String pickerId() {
    return (stockID ?? -1).toString();
  }

  @override
  String pickerName() {
    return stockName ?? '';
  }

  @override
  String toShow() {
    return stockName ?? '';
  }
}

class PickerSapDestination extends PickerItem {
  PickerSapDestination({
    required this.destinationId,
    required this.destinationName,
  });

  PickerSapDestination.fromJson(dynamic json) {
    destinationId = json['ZADGE_RCVER'];
    destinationName = json['ZADGE_RCVER_TEXT'];
  }

  String? destinationId;
  String? destinationName;

  @override
  String pickerId() {
    return destinationId??'';
  }

  @override
  String pickerName() {
    return destinationName ?? '';
  }

  @override
  String toShow() {
    return destinationName ?? '';
  }
}
