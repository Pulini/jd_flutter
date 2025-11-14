import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class PickingMaterialOrderInfo {
  String? orderNumber; //WOFNR  领料单号
  String? created; //UNAME  创建人
  String? date; //ERDAT  日期
  String? supplierNumber; //LIFNR  供应商编号
  String? supplierName; //NAME1  供应商名称

  //ZTDLL_GDMVT_MATNR_ITEM
  List<PickingMaterialOrderMaterialInfo>? materialList;

  PickingMaterialOrderInfo({
    this.orderNumber,
    this.created,
    this.date,
    this.supplierNumber,
    this.supplierName,
    this.materialList,
  });

  PickingMaterialOrderInfo.fromJson(dynamic json) {
    orderNumber = json['WOFNR'];
    created = json['UNAME'];
    date = json['ERDAT'];
    supplierNumber = json['LIFNR'];
    supplierName = json['NAME1'];

    materialList = [];
    if (json['ZTDLL_GDMVT_MATNR_ITEM'] != null) {
      json['ZTDLL_GDMVT_MATNR_ITEM'].forEach((v) {
        materialList!.add(PickingMaterialOrderMaterialInfo.fromJson(v));
      });
    }
  }
  int outTicketStatus(){
    if (materialList!.every((v) => v.outTicketStatus()==0)) {
      return 0;
    } else if (materialList!.every((v) =>  v.outTicketStatus()==1)) {
      return 1;
    } else {
      return 2;
    }
  }

  int getTimestamp() => DateTime.parse(date ?? '').millisecondsSinceEpoch;

  int colorSystemStatus() {
    if (materialList!.every((v) => v.colorFlg?.isEmpty == true)) {
      return 0;
    } else if (materialList!.every((v) =>  v.colorFlg?.isNotEmpty == true)) {
      return 1;
    } else {
      return 2;
    }
  }

  String colorSystemStatusText() {
    var status = colorSystemStatus();
    if (status == 0) {
      return 'picking_material_order_not_have_color_system'.tr;
    } else if (status == 1) {
      return 'picking_material_order_have_color_system'.tr;
    } else {
      return 'picking_material_order_partial_color_system'.tr;
    }
  }

  Color colorSystemStatusColor() {
    var status = colorSystemStatus();
    if (status == 0) {
      return Colors.red.shade700;
    } else if (status == 1) {
      return Colors.green.shade700;
    } else {
      return Colors.orange.shade700;
    }
  }

  int pickedStatus() {
    if (materialList!.every((v) => v.pickedStatus() == 0)) {
      return 0;
    } else if (materialList!.every((v) => v.pickedStatus() == 1)) {
      return 1;
    } else {
      return 2;
    }
  }


  String pickedStatusText() {
    var status = pickedStatus();
    if (status == 0) {
      return 'picking_material_order_not_deliver'.tr;
    } else if (status == 1) {
      return 'picking_material_order_delivered'.tr;
    } else {
      return 'picking_material_order_partial_delivered'.tr;
    }
  }

  Color pickedStatusColor() {
    if (materialList != null && materialList!.isNotEmpty) {
      var status = pickedStatus();
      if (status == 0) {
        return Colors.red.shade700;
      } else if (status == 1) {
        return Colors.green.shade700;
      } else {
        return Colors.orange.shade700;
      }
    } else {
      return Colors.grey;
    }
  }

  int preparedMaterialsStatus() {
    if (materialList!.every((v) => v.preparedMaterialsStatus() == 0)) {
      return 0;
    } else if (materialList!.every((v) => v.preparedMaterialsStatus() == 1)) {
      return 1;
    } else {
      return 2;
    }
  }

  String preparedMaterialsStatusText() {
    var status = preparedMaterialsStatus();
    if (status == 0) {
      return 'picking_material_order_not_prepared'.tr;
    } else if (status == 1) {
      return 'picking_material_order_prepared'.tr;
    } else {
      return 'picking_material_order_preparing'.tr;
    }
  }

  Color preparedMaterialsStatusColor() {
    var status = preparedMaterialsStatus();
    if (status == 0) {
      return Colors.red.shade700;
    } else if (status == 1) {
      return Colors.green.shade700;
    } else {
      return Colors.orange.shade700;
    }
  }
}

class PickingMaterialOrderMaterialInfo {
  bool isBasicUnit = true;

  String? materialCode; //MATNR  物料编码
  String? materialName; //ZMAKTX  物料描述
  String? instructionNo; //KDAUF  指令号
  double? demandQty; //BDMNG  需求数量F
  double? pickedQty; //ZZAEMNG  已领数量
  double? realTimeInventory; //LABST  即时库存
  String? basicUnit; //MEINS  基本单位
  String? commonUnit; //MEINH  常用单位
  double? basicMeasurementUnitNumerator; //UMREZ  分子
  double? basicMeasurementUnitDenominator; //UMREN  分母
  String? colorFlg; //ZZFSFLG  是否配色
  //ZTDLL_GDMVT_WOLNR_ITEM
  List<PickingMaterialOrderMaterialDetailLineInfo>? lineList;

  PickingMaterialOrderMaterialInfo({
    this.materialCode,
    this.materialName,
    this.instructionNo,
    this.demandQty,
    this.pickedQty,
    this.basicUnit,
    this.realTimeInventory,
    this.commonUnit,
    this.basicMeasurementUnitNumerator,
    this.basicMeasurementUnitDenominator,
    this.colorFlg,
    this.lineList,
  });

  PickingMaterialOrderMaterialInfo.fromJson(dynamic json) {
    materialCode = json['MATNR'];
    materialName = json['ZMAKTX'];
    instructionNo = json['KDAUF'];
    demandQty = json['BDMNG'];
    pickedQty = json['ZZAEMNG'];
    basicUnit = json['MEINS'];
    realTimeInventory = json['LABST'];
    commonUnit = json['MEINH'];
    basicMeasurementUnitNumerator = json['UMREZ'].toString().toDoubleTry();
    basicMeasurementUnitDenominator = json['UMREN'].toString().toDoubleTry();
    colorFlg = json['ZZFSFLG'];
    lineList = [];
    if (json['ZTDLL_GDMVT_WOLNR_ITEM'] != null) {
      json['ZTDLL_GDMVT_WOLNR_ITEM'].forEach((v) {
        lineList!.add(PickingMaterialOrderMaterialDetailLineInfo.fromJson(v));
      });
    }
    if (commonUnit?.isEmpty == true) commonUnit = basicUnit;
  }

  double canBasicPickingQty() => demandQty.sub(pickedQty ?? 0);

  double canCommonPickingQty() {
    var b = canBasicPickingQty();
    var c = b.div(getProportion());
    return c;
  }

  double basicPickingQty() =>
      lineList!.map((v) => v.pickingQty).reduce((a, b) => a.add(b));

  double commonPickingQty() {
    var b = basicPickingQty();
    var c = b.div(getProportion());
    return c;
  }

  double basicPreparingMaterialsQty() =>
      lineList!.map((v) => v.preparingMaterialsQty).reduce((a, b) => a.add(b));

  double commonPreparingMaterialsQty() {
    var b = basicPreparingMaterialsQty();
    var c = b.div(getProportion());
    return c;
  }

  double canBasicPreparingMaterialsQty() {
    var v = lineList!.map((v) => v.demandQty ?? 0).reduce((a, b) => a.add(b));
    return v;
  }

  double canCommonPreparingMaterialsQty() {
    var b = canBasicPreparingMaterialsQty();
    var c = b.div(getProportion());
    return c;
  }

  int  outTicketStatus() {
    if (lineList!.every((v) => v.hasOutTicket?.isEmpty==true)) {
      return 0;
    } else if (lineList!.every((v) => v.hasOutTicket?.isNotEmpty == true)) {
      return 1;
    } else {
      return 2;
    }
  }


  String outTicketStatusText() {
    var status = outTicketStatus();
    if (status == 0) {
      return 'picking_material_order_not_have_out_ticket'.tr;
    } else if (status == 1) {
      return 'picking_material_order_have_out_ticket'.tr;
    } else {
      return 'picking_material_order_partial_out_ticket'.tr;
    }
  }
  Color  outTicketStatusColor() {
    var status = outTicketStatus();
    if (status == 0) {
      return Colors.red.shade700;
    } else if (status == 1) {
      return Colors.green.shade700;
    } else {
      return Colors.orange.shade700;
    }
  }

  Color pickingStatusColor() {
    if (canBasicPickingQty() == 0) {
      return Colors.grey;
    } else {
      var status = pickingStatus();
      if (status == 0) {
        return Colors.red.shade700;
      } else if (status == 1) {
        return Colors.green.shade700;
      } else {
        return Colors.orange.shade700;
      }
    }
  }

  String pickedStatusText() {
    var status = pickedStatus();
    if (status == 0) {
      return 'picking_material_order_not_deliver'.tr;
    } else if (status == 1) {
      return 'picking_material_order_delivered'.tr;
    } else {
      return 'picking_material_order_partial_delivered'.tr;
    }
  }

  Color preparedMaterialsStatusColor() {
    var status = preparedMaterialsStatus();
    if (status == 0) {
      return Colors.red.shade700;
    } else if (status == 1) {
      return Colors.green.shade700;
    } else {
      return Colors.orange.shade700;
    }
  }

  String preparedMaterialsStatusText() {
    var status = preparedMaterialsStatus();
    if (status == 0) {
      return 'picking_material_order_not_prepared'.tr;
    } else if (status == 1) {
      return 'picking_material_order_prepared'.tr;
    } else {
      return 'picking_material_order_preparing'.tr;
    }
  }

  int pickedStatus() {
    if (lineList!.every((v) => v.pickedStatus() == 0)) {
      return 0;
    } else if (lineList!.every((v) => v.pickedStatus() == 1)) {
      return 1;
    } else {
      return 2;
    }
  }

  int pickingStatus() {
    if (lineList!.every((v) => v.postingStatus() == 0)) {
      return 0;
    } else if (lineList!.every((v) => v.postingStatus() == 1)) {
      return 1;
    } else {
      return 2;
    }
  }

  int preparedMaterialsStatus() {
    if (lineList!.every((v) => v.preparedMaterialsStatus() == 0)) {
      return 0;
    } else if (lineList!.every((v) => v.preparedMaterialsStatus() == 1)) {
      return 1;
    } else {
      return 2;
    }
  }

  bool isOnlyOneUnit() =>
      (basicMeasurementUnitNumerator == basicMeasurementUnitDenominator) &&
      (commonUnit == basicUnit);

  String getMaterial() => '($materialCode) $materialName';

  double getProportion() =>
      basicMeasurementUnitNumerator.div(basicMeasurementUnitDenominator ?? 1);

  double getCommonDemandQty() =>
      isOnlyOneUnit() ? demandQty ?? 0 : demandQty.div(getProportion());

  double getCommonPickingQty() =>
      isOnlyOneUnit() ? pickedQty ?? 0 : pickedQty.div(getProportion());

  String getBasicDemandQtyText() => '${demandQty.toShowString()}$basicUnit';

  String getCommonDemandQtyText() =>
      '${getCommonDemandQty().toFixed(3).toShowString()}$commonUnit';

  String getBasicPickingQtyText() => '${pickedQty.toShowString()}$basicUnit';

  String getCommonPickingQtyText() =>
      '${getCommonPickingQty().toFixed(3).toShowString()}$commonUnit';

  void setLinesBasicPickingQty(double pickingQty) {
    _setLinesPickingQty(pickingQty);
  }

  void setLinesCommonPickingQty(double pickingQty) {
    _setLinesPickingQty(pickingQty.mul(getProportion()));
  }

  void _setLinesPickingQty(double pickingQty) {
    var total = pickingQty;
    lineList?.forEach((v) {
      var canPick = v.canPickingQty();
      if (total.sub(canPick) > 0) {
        v.pickingQty = canPick;
        total = total.sub(canPick);
      } else {
        v.pickingQty = total;
        total = 0;
      }
    });
  }

  void setLinesBasicPreparedMaterialsQty(double qty) {
    _setLinesPreparedMaterialsQty(qty);
  }

  void setLinesCommonPreparedMaterialsQty(double qty) {
    _setLinesPreparedMaterialsQty(qty.mul(getProportion()));
  }

  void _setLinesPreparedMaterialsQty(double qty) {
    var total = qty;
    lineList?.forEach((v) {
      var canPreparing = v.demandQty ?? 0;
      if (total.sub(canPreparing) > 0) {
        v.preparingMaterialsQty = canPreparing;
        total = total.sub(canPreparing);
      } else {
        v.preparingMaterialsQty = total;
        total = 0;
      }
    });
  }
}

class PickingMaterialOrderMaterialDetailLineInfo {
  String? lineNo; //WOLNR  项目号
  double? demandQty; //BDMNG  需求数量
  double? pickedQty; //ZZAEMNG  已领数量
  double? preparedMaterialsQty; //BDMNG_BH 以备料数
  String? hasOutTicket; //ISOAOUTDOOR 是否有出门单

  double pickingQty = 0; //本次领取
  double preparingMaterialsQty = 0; //本次备料数

  PickingMaterialOrderMaterialDetailLineInfo({
    this.lineNo,
    this.demandQty,
    this.pickedQty,
    this.preparedMaterialsQty,
  });

  PickingMaterialOrderMaterialDetailLineInfo.fromJson(dynamic json) {
    lineNo = json['WOLNR'];
    demandQty = json['BDMNG'];
    pickedQty = json['ZZAEMNG'];
    preparedMaterialsQty = json['BDMNG_BH'];
    hasOutTicket = json['ISOAOUTDOOR'];
    pickingQty = canPickingQty();
    preparingMaterialsQty = preparedMaterialsQty ?? 0;
  }

  int pickedStatus() {
    if (pickedQty == 0) {
      return 0; //未发货
    } else if (demandQty == pickedQty) {
      return 1; //已发货
    } else {
      return 2; //部分发货
    }
  }

  int postingStatus() {
    if (pickingQty == 0) {
      return 0; //不过账
    } else if (canPickingQty() == pickingQty) {
      return 1; //全部过账
    } else {
      return 2; //过账部分
    }
  }

  int preparedMaterialsStatus() {
    if (0 == preparingMaterialsQty) {
      return 0; //未备料
    } else if (demandQty == preparingMaterialsQty) {
      return 1; //已备料完成
    } else {
      return 2; //部分备料
    }
  }

  double canPickingQty() => demandQty.sub(pickedQty ?? 0);
}

class PickingMaterialOrderPrintInfo {
  String? orderNumber; //WOFNR  领料单号
  String? date; //ERDAT  日期
  String? supplierNumber; //LIFNR  供应商编号
  String? supplierName; //LIF_NAME1  供应商名称
  String? factoryNo; //工厂  WERKS
  String? factoryName; //工厂名称 WER_NAME1
  String? contractNo; //合同号 EBELNS
  // ZTDLL_PRINT_MATNR_ITEM
  List<PickingMaterialOrderPrintMaterialInfo>? materialList;

  PickingMaterialOrderPrintInfo({
    this.orderNumber,
    this.date,
    this.supplierNumber,
    this.supplierName,
    this.factoryNo,
    this.factoryName,
    this.contractNo,
    this.materialList,
  });

  PickingMaterialOrderPrintInfo.fromJson(dynamic json) {
    orderNumber = json['WOFNR'];
    date = json['ERDAT'];
    supplierNumber = json['LIFNR'];
    supplierName = json['LIF_NAME1'];
    factoryNo = json['WERKS'];
    factoryName = json['WER_NAME1'];
    contractNo = json['EBELNS'];
    materialList = [];
    if (json['ZTDLL_PRINT_MATNR_ITEM'] != null) {
      json['ZTDLL_PRINT_MATNR_ITEM'].forEach((v) {
        materialList!.add(PickingMaterialOrderPrintMaterialInfo.fromJson(v));
      });
    }
  }
}

class PickingMaterialOrderPrintMaterialInfo {
  String? materialCode; //MATNR  物料编码
  String? materialName; //ZMAKTX  物料描述
  double? contractOweQty; //BDMNG_QS  合同欠数
  String? basicUnit; //MEINS  基本单位
  String? warehouseKeeper; //USNAM 仓库员
  List<PickingMaterialOrderPrintMaterialSubInfo>? materialSubList;



  PickingMaterialOrderPrintMaterialInfo({
    this.materialCode,
    this.materialName,
    this.contractOweQty,
    this.basicUnit,
    this.warehouseKeeper,
    this.materialSubList,

  });

  PickingMaterialOrderPrintMaterialInfo.fromJson(dynamic json) {
    materialCode = json['MATNR'];
    materialName = json['ZMAKTX'];
    contractOweQty = json['BDMNG_QS'].toString().toDoubleTry();
    basicUnit = json['MEINS'];
    warehouseKeeper = json['USNAM'];
    materialSubList = [];
    if (json['ZTDLL_PRINT_MATNR_ITEM2'] != null) {
      json['ZTDLL_PRINT_MATNR_ITEM2'].forEach((v) {
        materialSubList!.add(PickingMaterialOrderPrintMaterialSubInfo.fromJson(v));
      });
    }
  }
}

class PickingMaterialOrderPrintMaterialSubInfo {
  String? typeBody; //ZZGCXT  型体
  String? instruction; //VBELN  指令
  String? colorInfo; //ZCOLOR  色系
  String? size; //ZSIZE1  尺码
  String? batchNo; //CHARG  批次号
  String? warehouseNumber; //LGORT  库存仓库编号
  String? warehouseName; //LGOBE  库存仓库名称
  double? realTimeInventory; //LABST  即时库存
  String? location; //ZLOCAL  库位
  double? contractQty; //BDMNG_HT  合同数量
  double? shouldInventoryQty; //BDMNG  应备货数
  double? totalInventoryQty; //BDMNG_LJ  累计备货数
  double? contractOweQty; //BDMNG_QS  合同欠数
  String? subBasicUnit; //MEINS  基本单位


  PickingMaterialOrderPrintMaterialSubInfo({
    this.typeBody,
    this.instruction,
    this.colorInfo,
    this.size,
    this.batchNo,
    this.warehouseNumber,
    this.warehouseName,
    this.realTimeInventory,
    this.location,
    this.contractQty,
    this.shouldInventoryQty,
    this.totalInventoryQty,
    this.contractOweQty,
    this.subBasicUnit,

  });

  PickingMaterialOrderPrintMaterialSubInfo.fromJson(dynamic json) {
    typeBody = json['ZZGCXT'];
    instruction = json['VBELN'];
    colorInfo = json['ZCOLOR'];
    size = json['ZSIZE1'];
    batchNo = json['CHARG'];
    warehouseNumber = json['LGORT'];
    warehouseName = json['LGOBE'];
    realTimeInventory = json['LABST'].toString().toDoubleTry();
    location = json['ZLOCAL'];
    contractQty = json['BDMNG_HT'].toString().toDoubleTry();
    shouldInventoryQty = json['BDMNG'].toString().toDoubleTry();
    totalInventoryQty = json['BDMNG_LJ'].toString().toDoubleTry();
    contractOweQty = json['BDMNG_QS'].toString().toDoubleTry();
    subBasicUnit = json['MEINS'];

  }
}
