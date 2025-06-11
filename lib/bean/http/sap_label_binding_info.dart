import 'package:jd_flutter/utils/utils.dart';

class SapLabelBindingInfo {
  bool isBoxLabel = false; //	标签类型  ZBQLX (05大标 其余小标)
  String? pieceNo; //	件号  ZPIECE_NO
  String? labelID; //标签ID BQID
  String? boxLabelID; //	箱标（大标）  ZDBBQID
  String? COMAD; //缅甸批文成分 Composition of Myanmar approval documents  ZMATCOM
  String? COMADE; //缅甸批文成分 英文  ZMATCOM_E
  String? isTradeFactory; //是否贸易工厂  ZTRADE

  double? long; //	长 ZZCJC
  double? width; //	宽 ZZCJK
  double? height; //	高 ZZCJG
  double? outWeight; //	外包装重量 ZNTGEW_PZ

  String? factoryNo; //工厂  WERKS
  String? supplierNumber; //供应商编号  LIFNR
  String? materialsType; //	物料大类  ZMATNRCAT
  String? customsDeclarationType; //报关形式  ZCUSDECLARATYPE
  String? supplementType; //补单  ZISBD

  SapLabelBindingInfo({
    this.labelID,
    this.supplierNumber,
    this.factoryNo,
    this.customsDeclarationType,
    this.isTradeFactory,
    this.isBoxLabel = false,
    this.pieceNo,
    this.long,
    this.width,
    this.height,
    this.boxLabelID,
    this.materialsType,
    this.COMAD,
    this.COMADE,
    this.supplementType,
    this.outWeight,
  });

  SapLabelBindingInfo.fromJson(dynamic json) {
    labelID = json['BQID'];
    supplierNumber = json['LIFNR'];
    factoryNo = json['WERKS'];
    customsDeclarationType = json['ZCUSDECLARATYPE'];
    isTradeFactory = json['ZTRADE'];
    isBoxLabel = json['ZBQLX'] == '05';
    pieceNo = json['ZPIECE_NO'];
    materialsType = json['ZMATNRCAT'];
    long = json['ZZCJC'].toString().toDoubleTry();
    width = json['ZZCJK'].toString().toDoubleTry();
    height = json['ZZCJG'].toString().toDoubleTry();
    boxLabelID = json['ZDBBQID'];
    COMAD = json['ZMATCOM'];
    COMADE = json['ZMATCOM_E'];
    supplementType = json['ZISBD'];
    outWeight = json['ZNTGEW_PZ'];
  }

  String getBoxLabelID() => isBoxLabel ? labelID ?? '' : boxLabelID ?? '';

  String labelType() =>
      '$factoryNo - $supplierNumber - $materialsType - $customsDeclarationType - $supplementType';
}

class SapLabelBindingPrintInfo {
  bool isBoxLabel = false; //	标签类型  ZBQLX (05大标 其余小标)
  String? pieceNo; //	件号  ZPIECE_NO
  String? labelID; //标签ID BQID
  String? boxLabelID; //	箱标（大标）  ZDBBQID
  String? COMAD; //缅甸批文成分 Composition of Myanmar approval documents  ZMATCOM
  String? COMADE; //缅甸批文成分 英文  ZMATCOM_E
  String? isTradeFactory; //是否贸易工厂  ZTRADE

  double? long; //	长 ZZCJC
  double? width; //	宽 ZZCJK,
  double? height; //	高 ZZCJG
  double? outWeight; //	外包装重量 ZNTGEW_PZ

  String? factoryNo; //工厂  WERKS
  String? supplierNumber; //供应商编号  LIFNR
  String? materialsType; //	物料大类  ZMATNRCAT
  String? customsDeclarationType; //报关形式  ZCUSDECLARATYPE
  String? supplementType; //补单  ZISBD

  String? isMixMaterial; //	否混物料 是：'X'  否：''  ZMIX
  String? labelStatus; //	标签状态  ZBQZT
  String? referenceSalesOrderNo; //	参考销售单号  POSNR
  double? grossWeight; //	毛重  BRGEW
  String? creator; //	创建者 ERNAM
  String? creationDate; //	创建日期  ERDAT
  int? printingFrequency; //	打印次数  ZDYCS
  String? manufactureDate; //	生产日期  ZMADAT
  int? totalPieceQty; //	总件数 ZTTLCTN
  int? pieceQty; //	当前件数  ZCURCTN
  String? remarks; //	备注  ZMSGTT
  String? deleteFlag; //	删除标记  DELFLG
  String? materialNumber; //物料编号  MATNR
  String? materialName; //物料名称 ZMAKTX
  String? materialEnglishName; //物料英文名称 ZMAKTX_E
  String? salesOrder; //销售订单号  VBELN
  String? size; //尺码  SIZE1
  String? materialCategory; //物料类别  ATTYP
  double? inBoxQty; //装箱数量 ZXNUM
  String? unit; //单位 MEINS
  String? unitEnglish; //英文单位  MEINS_E
  String? companyNumber; //公司代码  BUKRS
  double? volume; //装载体积  LADEVOL
  double? netWeight; //净重  NTGEW
  String? trackNo; //跟踪号 ZTRACKNO
  String? customer; //客户  NAME1
  String? shipToParty; //Ship-To Party SHIPTO
  String? requirementDate; //需求日期 ZEINDT
  String? materialGroup; //物料组  MATKL
  String? salesAndDistributionVoucher; //销售和分销凭证号  ZZVBELN
  String? part; //部位  ZMDBW
  String? instructions; //指令 ZVBELN_ORI
  String? customerSalesOrderNo; //客人销售订单号  ZKVBELN
  String? purchaseOrder; //采购订单  EBELN
  String? purchaseOrderLine; //采购订单项目号  EBELP
  double? capacity; //箱容 ZZXR
  String? generalMaterialNumber; //一般可配置物料  SATNR
  String? materialDescription; //物料长描述  ZMAKTX_YB
  String? materialEnglishDescription; //物料长描述英文  ZMAKTX_YB_E
  String? factoryType; //工厂型体 ZZXTNO
  String? factoryDescription; //工厂描述  NAME1_WER
  String? companyNumberDescription; //公司代码描述  BUTXT

  SapLabelBindingPrintInfo({
    this.labelID,
    this.supplierNumber,
    this.factoryNo,
    this.customsDeclarationType,
    this.isTradeFactory,
    this.isBoxLabel = false,
    this.pieceNo,
    this.long,
    this.width,
    this.height,
    this.boxLabelID,
    this.materialsType,
    this.COMAD,
    this.COMADE,
    this.supplementType,
    this.outWeight,
    this.materialNumber,
    this.materialName,
    this.materialEnglishName,
    this.salesOrder,
    this.size,
    this.materialCategory,
    this.inBoxQty,
    this.unit,
    this.unitEnglish,
    this.companyNumber,
    this.volume,
    this.netWeight,
    this.trackNo,
    this.customer,
    this.shipToParty,
    this.requirementDate,
    this.materialGroup,
    this.salesAndDistributionVoucher,
    this.part,
    this.instructions,
    this.customerSalesOrderNo,
    this.purchaseOrder,
    this.purchaseOrderLine,
    this.capacity,
    this.generalMaterialNumber,
    this.materialDescription,
    this.materialEnglishDescription,
    this.factoryType,
    this.factoryDescription,
    this.companyNumberDescription,
    this.referenceSalesOrderNo,
    this.grossWeight,
    this.creator,
    this.creationDate,
    this.printingFrequency,
    this.manufactureDate,
    this.totalPieceQty,
    this.pieceQty,
    this.remarks,
    this.labelStatus,
    this.deleteFlag,
    this.isMixMaterial,
  });

  SapLabelBindingPrintInfo.fromJson(dynamic json) {
    labelID = json['BQID'];
    supplierNumber = json['LIFNR'];
    factoryNo = json['WERKS'];
    customsDeclarationType = json['ZCUSDECLARATYPE'];
    isTradeFactory = json['ZTRADE'];
    isBoxLabel = json['ZBQLX'] == '05';
    pieceNo = json['ZPIECE_NO'];
    materialsType = json['ZMATNRCAT'];
    long = json['ZZCJC'].toString().toDoubleTry();
    width = json['ZZCJK'].toString().toDoubleTry();
    height = json['ZZCJG'].toString().toDoubleTry();
    boxLabelID = json['ZDBBQID'];
    COMAD = json['ZMATCOM'];
    COMADE = json['ZMATCOM_E'];
    supplementType = json['ZISBD'];
    outWeight = json['ZNTGEW_PZ'];
    materialNumber = json['MATNR'];
    materialName = json['ZMAKTX'];
    materialEnglishName = json['ZMAKTX_E'];
    salesOrder = json['VBELN'];
    size = json['SIZE1'];
    materialCategory = json['ATTYP'];
    inBoxQty = json['ZXNUM'].toString().toDoubleTry();
    unit = json['MEINS'];
    unitEnglish = json['MEINS_E'];
    companyNumber = json['BUKRS'];
    volume = json['LADEVOL'].toString().toDoubleTry();
    netWeight = json['NTGEW'].toString().toDoubleTry();
    trackNo = json['ZTRACKNO'];
    customer = json['NAME1'];
    shipToParty = json['SHIPTO'];
    requirementDate = json['ZEINDT'];
    materialGroup = json['MATKL'];
    salesAndDistributionVoucher = json['ZZVBELN'];
    part = json['ZMDBW'];
    instructions = json['ZVBELN_ORI'];
    customerSalesOrderNo = json['ZKVBELN'];
    purchaseOrder = json['EBELN'];
    purchaseOrderLine = json['EBELP'];
    capacity = json['ZZXR'].toString().toDoubleTry();
    generalMaterialNumber = json['SATNR'];
    materialDescription = json['ZMAKTX_YB'];
    materialEnglishDescription = json['ZMAKTX_YB_E'];
    factoryType = json['ZZXTNO'];
    factoryDescription = json['NAME1_WER'];
    companyNumberDescription = json['BUTXT'];
    referenceSalesOrderNo = json['POSNR'];
    grossWeight = json['BRGEW'].toString().toDoubleTry();
    creator = json['ERNAM'];
    creationDate = json['ERDAT'];
    printingFrequency = json['ZDYCS'];
    manufactureDate = json['ZMADAT'];
    totalPieceQty = json['ZTTLCTN'];
    pieceQty = json['ZCURCTN'];
    remarks = json['ZMSGTT'];
    labelStatus = json['ZBQZT'];
    deleteFlag = json['DELFLG'];
    isMixMaterial = json['ZMIX'];
  }
}
