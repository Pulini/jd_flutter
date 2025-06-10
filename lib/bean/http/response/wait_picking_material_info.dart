import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

class CompanyInfo {
  String? companyName; // NAME1_WERKS
  String? companyID; // WERKS
  List<DepartmentInfo>? departmentList; // GT_ITEMS

  CompanyInfo({
    this.companyName,
    this.companyID,
    this.departmentList,
  });

  CompanyInfo.fromJson(Map<String, dynamic> json) {
    companyName = json['NAME1_WERKS'];
    companyID = json['WERKS'];
    if (json['GT_ITEMS'] != null) {
      departmentList = [];
      json['GT_ITEMS'].forEach((v) {
        departmentList!.add(DepartmentInfo.fromJson(v));
      });
    }
  }
}

class DepartmentInfo {
  String? departmentName; // KTEXT
  String? departmentID; // ARBPL

  DepartmentInfo({
    this.departmentName,
    this.departmentID,
  });

  DepartmentInfo.fromJson(Map<String, dynamic> json) {
    departmentName = json['KTEXT'];
    departmentID = json['ARBPL'];
  }
}

class WaitPickingMaterialOrderInfo {
  double? commonQuantity; //常用数量(常用可领料数量) = 需求数量 - 已领数量 ZZPLMNG1
  double? basicQuantity; //基本数量(基本可领料数量) = 需求数量 - 已领数量 ZZPLMNG
  double? demandQuantity; //需求数量BDMNG
  double? notPostedReceivedQuantity; //过账领料单数量ZZAWMNG1
  double? pickingQuantity; //领料数量(本次实发数量)ZZAEMNG
  double? workshopWarehousePickingQuantity; //车间仓库领料数量ZZAEMNG1
  double? unColorQuantity; //未配色数量WPSSL
  double? nowActIssuedCommonQuantity; //本次实发常用数量ZZAEMNG_CYSL
  String? storekeeper; //仓库员(APP登录)USNAM
  String? materialCollector; //领料员USNAM_LLY
  double? workCardUnReceivedQuantity; //

  RxBool isBaseUnit = false.obs;
  String modifyLocation = '';

  String? factoryNumber; //工厂 WERKS
  String? factoryName; ////工厂名称 NAME1_WERKS
  String? rawMaterialCode; //物料编码(原材料) MATNR_CL
  String? rawMaterialDescription; //物料描述(原材料)ZMAKTX_CL
  String? basicUnit; //基本单位ERFME
  String? commonUnits; //常用单位(领料单位)MEINH
  String? colorSeparationLogo; //分色标识ZZFSFLG
  String? batchIdentification; //批次标识XCHAR
  double? releaseQuantity; //下达数量ZXDSL
  double? unReleaseQuantity; //未下达数量ZXDSL_W
  double? receivedQuantity; //已领数量(出库累计数量)ZZAWMNG
  double? realTimeInventory; //即时库存LABST
  double? workshopStorageQuantity; //车间仓库存数量LABST1
  double? basicMeasurementUnitNumerator; //基本计量单位转换分子UMREZ
  double? basicMeasurementUnitDenominator; //基本计量单位转换分母UMREN
  String? pickingWarehouse; //仓库(领料仓库)LGORT
  String? workshopWarehouse; //车间仓库LGORT1
  String? multiCollarLogo; //多领标识ZSFDL
  String? materialCategory; //物料类别ATTYP
  String? location; //货位ZLOCAL
  List<WaitPickingMaterialOrderSubInfo>? items; //

  WaitPickingMaterialOrderInfo({
    this.factoryNumber,
    this.factoryName,
    this.rawMaterialCode,
    this.rawMaterialDescription,
    this.basicUnit,
    this.commonUnits,
    this.colorSeparationLogo,
    this.batchIdentification,
    this.commonQuantity,
    this.basicQuantity,
    this.releaseQuantity,
    this.unReleaseQuantity,
    this.demandQuantity,
    this.receivedQuantity,
    this.notPostedReceivedQuantity,
    this.realTimeInventory,
    this.pickingQuantity,
    this.workshopWarehousePickingQuantity,
    this.workshopStorageQuantity,
    this.unColorQuantity,
    this.workCardUnReceivedQuantity,
    this.nowActIssuedCommonQuantity,
    this.basicMeasurementUnitNumerator,
    this.basicMeasurementUnitDenominator,
    this.pickingWarehouse,
    this.workshopWarehouse,
    this.multiCollarLogo,
    this.storekeeper,
    this.materialCollector,
    this.materialCategory,
    this.location,
    this.items,
  }){
    modifyLocation=location??'';
  }

  factory WaitPickingMaterialOrderInfo.fromJson(dynamic json) {
    return WaitPickingMaterialOrderInfo(
      factoryNumber: json['FactoryNumber'],
      factoryName: json['FactoryName'],
      rawMaterialCode: json['RawMaterialCode'],
      rawMaterialDescription: json['RawMaterialDescription'],
      basicUnit: json['BasicUnit'],
      commonUnits: json['CommonUnits'],
      colorSeparationLogo: json['ColorSeparationLogo'],
      batchIdentification: json['BatchIdentification'],
      commonQuantity: json['CommonQuantity'].toString().toDoubleTry(),
      basicQuantity: json['BasicQuantity'].toString().toDoubleTry(),
      releaseQuantity: json['ReleaseQuantity'].toString().toDoubleTry(),
      unReleaseQuantity: json['UnReleaseQuantity'].toString().toDoubleTry(),
      demandQuantity: json['DemandQuantity'].toString().toDoubleTry(),
      receivedQuantity: json['ReceivedQuantity'].toString().toDoubleTry(),
      notPostedReceivedQuantity:
          json['NotPostedReceivedQuantity'].toString().toDoubleTry(),
      realTimeInventory: json['RealTimeInventory'].toString().toDoubleTry(),
      pickingQuantity: json['PickingQuantity'].toString().toDoubleTry(),
      workshopWarehousePickingQuantity:
          json['WorkshopWarehousePickingQuantity'].toString().toDoubleTry(),
      workshopStorageQuantity:
          json['WorkshopStorageQuantity'].toString().toDoubleTry(),
      unColorQuantity: json['UncolorQuantity'].toString().toDoubleTry(),
      workCardUnReceivedQuantity:
          json['WorkCardUnReceivedQuantity'].toString().toDoubleTry(),
      nowActIssuedCommonQuantity:
          json['NowActIssuedCommonQuantity'].toString().toDoubleTry(),
      basicMeasurementUnitNumerator:
          json['BasicMeasurementUnitNumerator'].toString().toDoubleTry(),
      basicMeasurementUnitDenominator:
          json['BasicMeasurementUnitDenominator'].toString().toDoubleTry(),
      pickingWarehouse: json['PickingWarehouse'],
      workshopWarehouse: json['WorkshopWarehouse'],
      multiCollarLogo: json['MultiCollarLogo'],
      storekeeper: json['Storekeeper'],
      materialCollector: json['MaterialCollector'],
      materialCategory: json['MaterialCategory'],
      location: json['Location'],
      items: json['Items'] != null
          ? (json['Items'] as List)
              .map((i) => WaitPickingMaterialOrderSubInfo.fromJson(i))
              .toList()
          : [],
    );
  }

  String getUnit() => isBaseUnit.value ? basicUnit ?? '' : commonUnits ?? '';

  double getProportion() =>
      basicMeasurementUnitNumerator.div(basicMeasurementUnitDenominator ?? 1);

  double getRealTimeInventory() => isBaseUnit.value
      ? realTimeInventory ?? 0
      : realTimeInventory.div(getProportion());

  double getLineInventory() => isBaseUnit.value
      ? workshopStorageQuantity ?? 0
      : workshopStorageQuantity.div(getProportion());

  double getTotal() => isBaseUnit.value
      ? releaseQuantity ?? 0
      : releaseQuantity.div(getProportion());

  double getUnRelease() => isBaseUnit.value
      ? unReleaseQuantity ?? 0
      : unReleaseQuantity.div(getProportion());

  double getReceived() => isBaseUnit.value
      ? receivedQuantity ?? 0
      : receivedQuantity.div(getProportion());

  double getPicking() => items!
      .map((v) => v.getPicking(getProportion(), isBaseUnit.value))
      .reduce((a, b) => a.add(b));

  double getUnreceived() => getTotal().sub(getReceived());

  String getPickingString(String stock) {
    var dl = 0;
    if (getLineInventory() >= getPicking()) {
      dl = 0;
    } else {
      dl = getPicking().sub(getLineInventory()).ceil();
    }
    if (multiCollarLogo == 'X' && stock.isNotEmpty) {
      return '${getPicking()} - ${getLineInventory()} = $dl ${getUnit()}';
    } else {
      return getPicking().toFixed(3).toShowString();
    }
  }

  bool hasSelected() => items!.any((v) => v.selectedCount() > 0);

  bool canBatchModify() =>
      items!.where((v) => v.models!.any((v2) => v2.isSelected.value)).length >
          1 || items!.every((v) => v.models!.any((v2) => v2.isSelected.value));

  bool batchDataNull() =>
      items!.every((v) => v.models!.every((v2) => v2.batch?.isEmpty == true));

  bool canViewBatch() => items!.any((v) => v.models!
      .any((v2) => v2.isSelected.value && v2.batch?.isNotEmpty == true));

  getPostBody(String pickerNumber) {
    return [
      for (var item2 in items!)
        for (var item3 in item2.getEffectiveSelection())
          {
            //领料部门ARBPL
            'PickingDepartment': item3.pickingDepartment,

            //生产订单号AUFNR
            'ProductionOrderNumber': item3.productionOrderNumber,

            //需求量BDMNG
            'Requirement': item3.demandQuantity.toShowString(),

            //过账日期BUDAT
            'PostingDate': item3.postingDate,

            //批号CHARG
            'Batch': item3.batch,

            //采购凭证号EBELN
            'PurchaseVoucherNo': item3.purchaseOrder,

            //采购凭证的项目编号EBELP
            'PurchaseDocumentItemNumber': item3.purchaseOrderLineItem,

            //基本单位ERFME
            'BasicUnit': basicUnit,

            //销售订单号KDAUF
            'SalesOrderNumber': item2.moNo,

            //销售订单行项KDPOS
            'SalesOrderLineItem': item3.moNoLineItem,

            //库存数量LABST
            'InventoryQuantity': item2.realTimeInventory.toShowString(),

            //车间仓数量LABST1
            'WorkshopsNumber': item2.workshopStorageQuantity.toShowString(),

            //领料仓LGORT
            'PickingWarehouse': pickingWarehouse,

            //车间仓LGORT1
            'WorkshopWarehouse': workshopWarehouse,

            //物料编号_材料18位MATNR_CL
            'MaterialCode': item3.rawMaterialCode,

            //领料单位MEINH
            'PickingUnit': commonUnits,

            //生产订单项目号POSNR
            'ProductionOrderItemNumber': item3.productionOrderLineItemNumber,

            //部件POTX1
            'Parts': item2.position,

            //预留/相关需求的编号RSNUM
            'ReservationNumber': item3.reservedNumber,

            //预留 / 相关需求的项目编号RSPOS
            'ReservedItemNumber': item3.reservedItems,

            //仓管员工号USNAM
            'WarehouseStaffNumber': userInfo?.number,

            //领料员工号USNAM_LLY
            'PickingStaffNumber': pickerNumber,

            //工厂WERKS
            'Factory': factoryNumber,

            //领料单号WOFNR
            'PickingOrderNo': item3.reservatedLastShipment,

            //领料单行项目WOLNR
            'PickingLineItem': item3.pickingLineItem,

            //多领标识ZSFDL
            'MultiCollarLogo': multiCollarLogo,

            //单据类型ZTYPE
            'DocumentType': item2.documentType,

            //下达数量ZXDSL
            'ReleaseQuantity': item3.releaseQuantity.toShowString(),

            //实际领料数ZZAEMNG
            'ActualPickingQuantity': item3.pickingQty.value.toShowString(),

            //车间仓领料数ZZAEMNG1
            'WorkshopWarehousePickingQuantity':
                item3.workshopWarehousePickingQuantity.toShowString(),

            //领料单数量ZZAWMNG
            'PickingListQuantity': item3.receivedQuantity.toShowString(),

            //未过账领料单数量ZZAWMNG1
            'UnpublishedPickingListQuantity':
                item3.notPostedReceivedQuantity.toShowString(),

            //分色标识ZZFSFLG
            'ColorSeparationLogo': colorSeparationLogo,

            //可领料数ZZPLMNG
            'PickingQuantity': item3.basicPickingQuantity.toShowString(),

            //常用可领料数ZZPLMNG1
            'CommonPickingQuantity': item3.commonPickingQuantity.toShowString(),

            //工厂型体编码ZZXTNO
            'FactoryTypeCode': item3.typeBody,

            //物料描述(原材料)ZMAKTX_CL
            'MaterialDescription': rawMaterialDescription,
          }
    ];
  }
  getSapPostBody(String pickerNumber) {
    return [
      for (var item2 in items!)
        for (var item3 in item2.getEffectiveSelection())
          {
            'ARBPL': item3.pickingDepartment,
            'AUFNR': item3.productionOrderNumber,
            'BDMNG': item3.demandQuantity.toShowString(),
            'BUDAT': item3.postingDate,
            'CHARG': item3.batch,
            'EBELN': item3.purchaseOrder,
            'EBELP': item3.purchaseOrderLineItem,
            'ERFME': basicUnit,
            'KDAUF': item2.moNo,
            'KDPOS': item3.moNoLineItem,
            'LABST': item2.realTimeInventory.toShowString(),
            'LABST1': item2.workshopStorageQuantity.toShowString(),
            'LGORT': pickingWarehouse,
            'LGORT1': workshopWarehouse,
            'MATNR_CL': item3.rawMaterialCode,
            'MEINH': commonUnits,
            'POSNR': item3.productionOrderLineItemNumber,
            'POTX1': item2.position,
            'RSNUM': item3.reservedNumber,
            'RSPOS': item3.reservedItems,
            'USNAM': userInfo?.number,//仓管员工号
            'USNAM_LLY': pickerNumber, //领料员工号
            'WERKS': factoryNumber,
            'WOFNR': item3.reservatedLastShipment,
            'WOLNR': item3.pickingLineItem,
            'ZSFDL': multiCollarLogo,
            'ZTYPE': item2.documentType,
            'ZXDSL': item3.releaseQuantity.toShowString(),
            'ZZAEMNG': item3.pickingQty.value.toShowString(),
            'ZZAEMNG1': item3.workshopWarehousePickingQuantity.toShowString(),
            'ZZAWMNG': item3.receivedQuantity.toShowString(),
            'ZZAWMNG1': item3.notPostedReceivedQuantity.toShowString(),
            'ZZFSFLG': colorSeparationLogo,
            'ZZPLMNG': item3.basicPickingQuantity.toShowString(),
            'ZZPLMNG1': item3.commonPickingQuantity.toShowString(),
            'ZZXTNO': item3.typeBody,
            'ZMAKTX_CL': rawMaterialDescription,
          }
    ];
  }
}

class WaitPickingMaterialOrderSubInfo {
  double? commonQuantity; //常用数量(常用可领料数量) = 需求数量 - 已领数量ZZPLMNG1
  double? basicQuantity; //基本数量(基本可领料数量) = 需求数量 - 已领数量ZZPLMNG
  double? demandQuantity; //需求数量BDMNG
  double? notPostedReceivedNum; //未过账领料单数量ZZAWMNG1
  double? pickingQuantity; //领料数量ZZAEMNG
  double? workshopWarehousePickingQuantity; //车间仓库领料数量ZZAEMNG1
  double? unColorQuantity; //未配色数量WPSSL
  double? workCardNotReceivedNum; //工单未领数GDWLS
  double? nowActIssuedCommonQuantity; //本次实发常用数量ZZAEMNG_CYSL

  String? documentType; //单据类型ZTYPE
  String? moNo; //指令KDAUF
  String? position; //部位POTX1
  double? releaseQuantity; //下达数量ZXDSL
  double? unReleaseQuantity; //未下达数量ZXDSL_W
  double? receivedQuantity; //已领数量ZZAWMNG
  double? realTimeInventory; //即时库存LABST
  double? workshopStorageQuantity; //车间仓库存数量LABST1
  String?
      msgType; //操作类型 01不可修改、02可修改数量（汇总、明细表批量修改）不可修改批次、03可修改数量（汇总、明细表批量修改）可修改批次（明细表修改）、04可修改数量（明细表单条修改）不可修改批次
  String? msg; //操作提示
  List<WaitPickingMaterialOrderModelInfo>? models;

  WaitPickingMaterialOrderSubInfo({
    required this.documentType,
    required this.moNo,
    required this.position,
    required this.commonQuantity,
    required this.basicQuantity,
    required this.releaseQuantity,
    required this.unReleaseQuantity,
    required this.demandQuantity,
    required this.receivedQuantity,
    required this.notPostedReceivedNum,
    required this.realTimeInventory,
    required this.pickingQuantity,
    required this.workshopWarehousePickingQuantity,
    required this.workshopStorageQuantity,
    required this.unColorQuantity,
    required this.workCardNotReceivedNum,
    required this.nowActIssuedCommonQuantity,
    required this.msgType,
    required this.msg,
    required this.models,
  });

  factory WaitPickingMaterialOrderSubInfo.fromJson(dynamic json) {
    return WaitPickingMaterialOrderSubInfo(
      documentType: json['DocumentType'],
      moNo: json['MoNo'],
      position: json['Position'],
      commonQuantity: json['CommonQuantity'].toString().toDoubleTry(),
      basicQuantity: json['BasicQuantity'].toString().toDoubleTry(),
      releaseQuantity: json['ReleaseQuantity'].toString().toDoubleTry(),
      unReleaseQuantity: json['UnReleaseQuantity'].toString().toDoubleTry(),
      demandQuantity: json['DemandQuantity'].toString().toDoubleTry(),
      receivedQuantity: json['ReceivedQuantity'].toString().toDoubleTry(),
      notPostedReceivedNum:
          json['NotPostedReceivedNum'].toString().toDoubleTry(),
      realTimeInventory: json['RealTimeInventory'].toString().toDoubleTry(),
      pickingQuantity: json['PickingQuantity'].toString().toDoubleTry(),
      workshopWarehousePickingQuantity:
          json['WorkshopWarehousePickingQuantity'].toString().toDoubleTry(),
      workshopStorageQuantity:
          json['WorkshopStorageQuantity'].toString().toDoubleTry(),
      unColorQuantity: json['UncolorQuantity'].toString().toDoubleTry(),
      workCardNotReceivedNum:
          json['WorkCardNotReceivedNum'].toString().toDoubleTry(),
      nowActIssuedCommonQuantity:
          json['NowActIssuedCommonQuantity'].toString().toDoubleTry(),
      msgType: json['MsgType'],
      msg: json['Msg'],
      models: json['Models'] != null
          ? (json['Models'] as List)
              .map((i) => WaitPickingMaterialOrderModelInfo.fromJson(i))
              .toList()
          : [],
    );
  }

  int selectedCount() => models!.where((v) => v.isSelected.value).length;

  List<WaitPickingMaterialOrderModelInfo> getEffectiveSelection() =>
      models!.where((v) => v.isEffectiveSelection()).toList();

  double getPicking(double proportion, bool isBaseUnit) => isBaseUnit
      ? models!
          .map((v) => v.isSelected.value ? v.pickingQty.value : 0.0)
          .reduce((a, b) => a.add(b))
      : models!
          .map((v) => v.isSelected.value ? v.pickingQty.value : 0.0)
          .reduce((a, b) => a.add(b))
          .div(proportion);

  double getRealTimeInventory(double proportion, bool isBaseUnit) =>
      isBaseUnit ? realTimeInventory ?? 0 : realTimeInventory.div(proportion);

  double getLineInventory(double proportion, bool isBaseUnit) => isBaseUnit
      ? workshopStorageQuantity ?? 0
      : workshopStorageQuantity.div(proportion);

  double getTotal(double proportion, bool isBaseUnit) =>
      isBaseUnit ? releaseQuantity ?? 0 : releaseQuantity.div(proportion);

  double getUnRelease(double proportion, bool isBaseUnit) =>
      isBaseUnit ? unReleaseQuantity ?? 0 : unReleaseQuantity.div(proportion);

  double getReceived(double proportion, bool isBaseUnit) =>
      isBaseUnit ? receivedQuantity ?? 0 : receivedQuantity.div(proportion);

  double getUnreceived(double proportion, bool isBaseUnit) =>
      getTotal(proportion, isBaseUnit).sub(getReceived(proportion, isBaseUnit));

  String getOrderType() {
    switch (documentType) {
      case '1':
        return '正单';
      case '2':
        return '正单委外';
      case '3':
        return '补单';
      case '4':
        return '补单委外';
      default:
        return '所有';
    }
  }
}

class WaitPickingMaterialOrderModelInfo {
  String? specifications; //规格GROES
  String? storekeeper; //仓库员USNAM_CKY
  String? halfMaterialCode; //物料编码(半成品)MATNR
  String? halfMaterialDescription; //物料描述(半成品)ZMAKTX
  double? productionQuantity; //生产数量PSMNG
  String? reservateLastShipment; //该预定的最后发货(关闭'X')KZEAR
  double? workCardNotReceivedQuantity; //工单未领数GDWLS

  RxBool isSelected = false.obs;
  RxDouble pickingQty = 0.0.obs;

  String? productionOrderNumber; //生产订单号AUFNR
  String? productionOrderLineItemNumber; //生产订单行项目号POSNR
  String? pickingDepartment; //领料部门ARBPL
  String? size; //尺码/数量SIZE1
  String? moNoLineItem; //指令行项目KDPOS
  String? typeBody; //型体ZZXTNO
  double? commonPickingQuantity; //常用数量(常用可领料数量) = 需求数量 - 已领数量ZZPLMNG1
  double? basicPickingQuantity; //基本数量(基本可领料数量) = 需求数量 - 已领数量ZZPLMNG
  double? releaseQuantity; //下达数量ZXDSL
  double? unReleaseQuantity; //未下达数量ZXDSL_W
  double? demandQuantity; //需求数量BDMNG
  double? receivedQuantity; //下达数量ZXDSL
  double? notPostedReceivedQuantity; //未过账领料单数量ZZAWMNG1
  String? location; //货位ZLOCAL
  double? actPickingQuantity; //领料数量(实际领料数)ZZAEMNG
  double? workshopWarehousePickingQuantity; //车间仓库领料数量ZZAEMNG1
  String? processedMaterialUnit; //被加工物料单位MEINS
  String? postingDate; //过账日期BUDAT
  String? purchaseOrder; //采购订单EBELN
  String? purchaseOrderLineItem; //采购订单行项目EBELP
  String? reservedNumber; //预留号RSNUM
  String? reservedItems; //预留项目RSPOS
  String? reservatedLastShipment; //领料单号WOFNR
  String? pickingLineItem; //领料单行项目WOLNR
  String? availableStock; //可用库存(除占用库存) = 即时库存 - 未过账领料单数量ZZPLABST
  String? batch; //批次CHARG
  double? unColorQuantity; //未配色数量WPSSL
  double? nowActIssuedCommonQuantity; //本次实发常用数量ZZAEMNG_CYSL
  String? outsourceProcedure; //外发工序 ZWFGX
  String? rawMaterialCode; //尺码物料编码 MATNR_CL
  String? colorSystem; //色系ZCOLOR

  WaitPickingMaterialOrderModelInfo({
    required this.productionOrderNumber,
    required this.productionOrderLineItemNumber,
    required this.pickingDepartment,
    required this.size,
    required this.moNoLineItem,
    required this.typeBody,
    required this.specifications,
    required this.commonPickingQuantity,
    required this.basicPickingQuantity,
    required this.releaseQuantity,
    required this.unReleaseQuantity,
    required this.demandQuantity,
    required this.receivedQuantity,
    required this.notPostedReceivedQuantity,
    required this.storekeeper,
    required this.location,
    required this.actPickingQuantity,
    required this.workshopWarehousePickingQuantity,
    required this.halfMaterialCode,
    required this.halfMaterialDescription,
    required this.productionQuantity,
    required this.processedMaterialUnit,
    required this.postingDate,
    required this.purchaseOrder,
    required this.purchaseOrderLineItem,
    required this.reservedNumber,
    required this.reservedItems,
    required this.reservateLastShipment,
    required this.reservatedLastShipment,
    required this.pickingLineItem,
    required this.availableStock,
    required this.batch,
    required this.unColorQuantity,
    required this.workCardNotReceivedQuantity,
    required this.nowActIssuedCommonQuantity,
    required this.outsourceProcedure,
    required this.rawMaterialCode,
    required this.colorSystem,
  }) {
    pickingQty.value = actPickingQuantity ?? 0;
  }

  factory WaitPickingMaterialOrderModelInfo.fromJson(dynamic json) {
    return WaitPickingMaterialOrderModelInfo(
      productionOrderNumber: json['ProductionOrderNumber'],
      productionOrderLineItemNumber: json['ProductionOrderLineItemNumber'],
      pickingDepartment: json['PickingDepartment'],
      size: json['Size'],
      moNoLineItem: json['MoNoLineItem'],
      typeBody: json['TypeBody'],
      specifications: json['Specifications'],
      commonPickingQuantity:
          json['CommonPickingQuantity'].toString().toDoubleTry(),
      basicPickingQuantity:
          json['BasicPickingQuantity'].toString().toDoubleTry(),
      releaseQuantity: json['ReleaseQuantity'].toString().toDoubleTry(),
      unReleaseQuantity: json['UnReleaseQuantity'].toString().toDoubleTry(),
      demandQuantity: json['DemandQuantity'].toString().toDoubleTry(),
      receivedQuantity: json['ReceivedQuantity'].toString().toDoubleTry(),
      notPostedReceivedQuantity:
          json['NotPostedReceivedQuantity'].toString().toDoubleTry(),
      storekeeper: json['Storekeeper'],
      location: json['Location'],
      actPickingQuantity: json['ActPickingQuantity'].toString().toDoubleTry(),
      workshopWarehousePickingQuantity:
          json['WorkshopWarehousePickingQuantity'].toString().toDoubleTry(),
      halfMaterialCode: json['HalfMaterialCode'],
      halfMaterialDescription: json['HalfMaterialDescription'],
      productionQuantity: json['ProductionQuantity'].toString().toDoubleTry(),
      processedMaterialUnit: json['ProcessedMaterialUnit'],
      postingDate: json['PostingDate'],
      purchaseOrder: json['PurchaseOrder'],
      purchaseOrderLineItem: json['PurchaseOrderLineItem'],
      reservedNumber: json['ReservedNumber'],
      reservedItems: json['ReservedItems'],
      reservateLastShipment: json['ReservateLastShipment'],
      reservatedLastShipment: json['ReservatedLastShipment'],
      pickingLineItem: json['PickingLineItem'],
      availableStock: json['AvailableStock'],
      batch: json['Batch'],
      unColorQuantity: json['UncolorQuantity'].toString().toDoubleTry(),
      workCardNotReceivedQuantity:
          json['WorkCardNotReceivedQuantity'].toString().toDoubleTry(),
      nowActIssuedCommonQuantity:
          json['NowActIssuedCommonQuantity'].toString().toDoubleTry(),
      outsourceProcedure: json['OutsourceProcedure'],
      rawMaterialCode: json['RawMaterialCode'],
      colorSystem: json['ColorSystem'],
    );
  }

  double getUnreceivedQty() => releaseQuantity.sub(receivedQuantity ?? 0);

  bool isEffectiveSelection() => isSelected.value && pickingQty.value > 0;
}

class ImmediateInventoryInfo {
  String? batch; //批次CHARG
  String? factory; //工厂WERKS
  String? locationDescription; //库位描述LGOBE
  String? materialCode; //物料编码MATNR
  String? productionOrderItemNumber; //生产订单项目号POSNR
  String? realTimeInventory; //即时库存LABST
  String? salesAndDistributionVoucherNumber; //销售和分销凭证号VBELN
  String? storageLocation; //存储位置LGORT

  ImmediateInventoryInfo({
    required this.batch,
    required this.factory,
    required this.locationDescription,
    required this.materialCode,
    required this.productionOrderItemNumber,
    required this.realTimeInventory,
    required this.salesAndDistributionVoucherNumber,
    required this.storageLocation,
  });

  factory ImmediateInventoryInfo.fromJson(dynamic json) {
    return ImmediateInventoryInfo(
      batch: json['Batch'],
      factory: json['Factory'],
      locationDescription: json['LocationDescription'],
      materialCode: json['MaterialCode'],
      productionOrderItemNumber: json['ProductionOrderItemNumber'],
      realTimeInventory: json['RealTimeInventory'],
      salesAndDistributionVoucherNumber:
          json['SalesAndDistributionVoucherNumber'],
      storageLocation: json['StorageLocation'],
    );
  }
}
