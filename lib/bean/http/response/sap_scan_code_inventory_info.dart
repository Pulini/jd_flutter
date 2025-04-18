import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

class InventoryPalletInfo {
  RxBool isBaseUnit = true.obs;
  RxBool isSelected = false.obs;
  RxDouble inventoryQty = 0.0.obs;

  String? inventoryForm; //盘点表单  ZPDBD
  int? inventoryProject; //盘点项目 ZPDXM
  String? factory; //工厂 WERKS
  String? storageLocation; //存储位置 LGORT
  String? warehouseLocation; //库位  ZLOCAL
  String? palletNumber; //托盘号 ZFTRAYNO
  String? labelId; //标签ID  BQID
  String? materialCode; //物料编号  MATNR
  String? batch; //批号  CHARG
  String? specialStockTag; //特殊库存标识  SOBKZ
  String? salesOrderNo; //销售订单号 KDAUF
  int? salesOrderLine; //销售订单行项  KDPOS
  String? originalSalesOrderNo; //原始销售订单号 ZZVBELN
  String? typeBody; //型体  ZZXTNO
  String? size; //尺码  SIZE1
  double? quantity; //数量   （库存） MENGE
  String? basicUnit; //基本计件单位  MEINS
  String? convertedUnits; //转换后单位 AUSME
  double? coefficient; //转换系数  ZCOEFFICIENT
  String? dispatchOrderNo; //派工单号  ZDISPATCH_NO
  String? labelStatus; //标签状态  ZBQZT
  double? firstInventoryQty; //初盘数量  ZMENGE_CP
  double? firstInventoryQtyDifference; //初盘数量差异  ZMNGCY_CP
  String? firstInventoryAuditor; //初盘人 ZERNAM_CP
  String? firstInventoryDate; //初盘日期  ZERDAT_CP
  String? firstInventoryTime; //初盘时间  ZERZET_CP
  double? secondInventoryQty; //复盘数量  ZMENGE_FP
  double? secondInventoryDifferences; //复盘差异数量  ZMNGCY_FP
  String? secondInventoryAuditor; //复盘人 ZERNAM_FP
  String? secondInventoryDate; //复盘日期  ZERDAT_FP
  String? secondInventoryTime; //复盘时间  ZERZET_FP
  String? secondInventoryProjectStatus; //盘点项目状态  ZSTATE_I
  String? deleteTag; //删除标记  ZDEL
  String? projectTextInfo; //项目文本信息  ZTEXT_I
  String? projectCreator; //创建对象的人员名称 ERNAM
  String? projectCreateDate; //记录创建日期  ERDAT
  String? inputTime; //输入时间  ERZET
  String? projectReviser; //更改对象用户的名称 AENAM
  String? finalModifiedDate; //最后更改的日期 AEDAT
  String? lastModifiedTime; //上一次做修改的时间 AEZET
  String? company; //集团  MANDT
  String? materialName; //物料名称  MAKTX

  InventoryPalletInfo({
    this.inventoryForm,
    this.inventoryProject,
    this.factory,
    this.storageLocation,
    this.warehouseLocation,
    this.palletNumber,
    this.labelId,
    this.materialCode,
    this.batch,
    this.specialStockTag,
    this.salesOrderNo,
    this.salesOrderLine,
    this.originalSalesOrderNo,
    this.typeBody,
    this.size,
    this.quantity,
    this.basicUnit,
    this.convertedUnits,
    this.coefficient,
    this.dispatchOrderNo,
    this.labelStatus,
    this.firstInventoryQty,
    this.firstInventoryQtyDifference,
    this.firstInventoryAuditor,
    this.firstInventoryDate,
    this.firstInventoryTime,
    this.secondInventoryQty,
    this.secondInventoryDifferences,
    this.secondInventoryAuditor,
    this.secondInventoryDate,
    this.secondInventoryTime,
    this.secondInventoryProjectStatus,
    this.deleteTag,
    this.projectTextInfo,
    this.projectCreator,
    this.projectCreateDate,
    this.inputTime,
    this.projectReviser,
    this.finalModifiedDate,
    this.lastModifiedTime,
    this.company,
    this.materialName,
  }) {
    if (convertedUnits?.isEmpty == true) convertedUnits = basicUnit;
  }

  factory InventoryPalletInfo.fromJson(dynamic json) {
    return InventoryPalletInfo(
      inventoryForm: json['ZPDBD'],
      inventoryProject: json['ZPDXM'],
      factory: json['WERKS'],
      storageLocation: json['LGORT'],
      warehouseLocation: json['ZLOCAL'],
      palletNumber: json['ZFTRAYNO'],
      labelId: json['BQID'],
      materialCode: json['MATNR'],
      batch: json['CHARG'],
      specialStockTag: json['SOBKZ'],
      salesOrderNo: json['KDAUF'],
      salesOrderLine: json['KDPOS'],
      originalSalesOrderNo: json['ZZVBELN'],
      typeBody: json['ZZXTNO'],
      size: json['SIZE1'],
      quantity: json['MENGE'].toString().toDoubleTry(),
      basicUnit: json['MEINS'],
      convertedUnits: json['AUSME'],
      coefficient: json['ZCOEFFICIENT'].toString().toDoubleTry(),
      dispatchOrderNo: json['ZDISPATCH_NO'],
      labelStatus: json['ZBQZT'],
      firstInventoryQty: json['ZMENGE_CP'].toString().toDoubleTry(),
      firstInventoryQtyDifference: json['ZMNGCY_CP'].toString().toDoubleTry(),
      firstInventoryAuditor: json['ZERNAM_CP'],
      firstInventoryDate: json['ZERDAT_CP'],
      firstInventoryTime: json['ZERZET_CP'],
      secondInventoryQty: json['ZMENGE_FP'].toString().toDoubleTry(),
      secondInventoryDifferences: json['ZMNGCY_FP'].toString().toDoubleTry(),
      secondInventoryAuditor: json['ZERNAM_FP'],
      secondInventoryDate: json['ZERDAT_FP'],
      secondInventoryTime: json['ZERZET_FP'],
      secondInventoryProjectStatus: json['ZSTATE_I'],
      deleteTag: json['ZDEL'],
      projectTextInfo: json['ZTEXT_I'],
      projectCreator: json['ERNAM'],
      projectCreateDate: json['ERDAT'],
      inputTime: json['ERZET'],
      projectReviser: json['AENAM'],
      finalModifiedDate: json['AEDAT'],
      lastModifiedTime: json['AEZET'],
      company: json['MANDT'],
      materialName: json['MAKTX'],
    );
  }

  Map<String, dynamic> toSubmitJson(
    bool isScan,
    String signatureNumber,
    String orderType,
  ) {
    switch (orderType) {
      case '10':
      case '20':
        firstInventoryAuditor = signatureNumber;
        firstInventoryDate = getDateYMD();
        firstInventoryTime = getTimeHms();
        if (isScan) firstInventoryQty = quantity;
        break;
      case '11':
      case '21':
        secondInventoryAuditor = signatureNumber;
        secondInventoryDate = getDateYMD();
        secondInventoryTime = getTimeHms();
        if (isScan) secondInventoryQty = quantity;
        break;
    }
    return toJson();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZPDBD'] = inventoryForm;
    map['ZPDXM'] = inventoryProject;
    map['WERKS'] = factory;
    map['LGORT'] = storageLocation;
    map['ZLOCAL'] = warehouseLocation;
    map['ZFTRAYNO'] = palletNumber;
    map['BQID'] = labelId;
    map['MATNR'] = materialCode;
    map['CHARG'] = batch;
    map['SOBKZ'] = specialStockTag;
    map['KDAUF'] = salesOrderNo;
    map['KDPOS'] = salesOrderLine;
    map['ZZVBELN'] = originalSalesOrderNo;
    map['ZZXTNO'] = typeBody;
    map['SIZE1'] = size;
    map['MENGE'] = quantity;
    map['MEINS'] = basicUnit;
    map['AUSME'] = convertedUnits;
    map['ZCOEFFICIENT'] = coefficient;
    map['ZDISPATCH_NO'] = dispatchOrderNo;
    map['ZBQZT'] = labelStatus;
    map['ZMENGE_CP'] = firstInventoryQty;
    map['ZMNGCY_CP'] = firstInventoryQtyDifference;
    map['ZERNAM_CP'] = firstInventoryAuditor;
    map['ZERDAT_CP'] = firstInventoryDate;
    map['ZERZET_CP'] = firstInventoryTime;
    map['ZMENGE_FP'] = secondInventoryQty;
    map['ZMNGCY_FP'] = secondInventoryDifferences;
    map['ZERNAM_FP'] = secondInventoryAuditor;
    map['ZERDAT_FP'] = secondInventoryDate;
    map['ZERZET_FP'] = secondInventoryTime;
    map['ZSTATE_I'] = secondInventoryProjectStatus;
    map['ZDEL'] = deleteTag;
    map['ZTEXT_I'] = projectTextInfo;
    map['ERNAM'] = projectCreator;
    map['ERDAT'] = projectCreateDate;
    map['ERZET'] = inputTime;
    map['AENAM'] = projectReviser;
    map['AEDAT'] = finalModifiedDate;
    map['AEZET'] = lastModifiedTime;
    map['MANDT'] = company;
    map['MAKTX'] = materialName;
    return map;
  }

  String getStateText() {
    switch (secondInventoryProjectStatus) {
      case '10':
        return 'sap_inventory_status_10'.tr;
      case '11':
        return 'sap_inventory_status_11'.tr;
      case '12':
        return 'sap_inventory_status_12'.tr;
      case '20':
        return 'sap_inventory_status_20'.tr;
      case '21':
        return 'sap_inventory_status_21'.tr;
      case '22':
        return 'sap_inventory_status_22'.tr;
      default:
        return '';
    }
  }

  String getUnit() => isBaseUnit.value ? basicUnit ?? '' : convertedUnits ?? '';

  double getQuantity() {
    if (isBaseUnit.value) {
      return quantity ?? 0;
    } else {
      return quantity.div(coefficient ?? 0);
    }
  }
  double getInventoryQty() {
    if (isBaseUnit.value) {
      return inventoryQty.value;
    } else {
      return inventoryQty.value.div(coefficient ?? 0);
    }
  }
  double setInventoryQty(double qty) {
    if (isBaseUnit.value) {
      return inventoryQty.value=qty;
    } else {
      return inventoryQty.value=qty.div(coefficient ?? 0);
    }
  }

  double getInventoryQtyPercent() {
    if (inventoryQty.value > (quantity ?? 0)) {
      return 1;
    } else {
      return inventoryQty.value / (quantity ?? 0);
    }
  }

  double getInventoryQtyOwePercent() {
    if (inventoryQty.value > (quantity ?? 0)) {
      return 0;
    } else {
      return ((quantity ?? 0) - inventoryQty.value) / (quantity ?? 0);
    }
  }
}
