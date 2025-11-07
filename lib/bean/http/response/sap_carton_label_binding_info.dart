import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class SapLabelBindingInfo {
  bool isBoxLabel = false; //	标签类型  ZBQLX (05大标 其余小标)
  String? pieceNo; //	件号  ZPIECE_NO
  String? labelID; //标签ID BQID
  String? boxLabelID; //	箱标（大标）  ZDBBQID
  String?
      myanmarApprovalDocuments; //缅甸批文成分 Composition of Myanmar approval documents  ZMATCOM
  String? myanmarApprovalDocumentsEnglish; //缅甸批文成分 英文  ZMATCOM_E
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
    this.myanmarApprovalDocuments,
    this.myanmarApprovalDocumentsEnglish,
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
    myanmarApprovalDocuments = json['ZMATCOM'];
    myanmarApprovalDocumentsEnglish = json['ZMATCOM_E'];
    supplementType = json['ZISBD'];
    outWeight = json['ZNTGEW_PZ'];
  }

  String getBoxLabelID() => isBoxLabel ? labelID ?? '' : boxLabelID ?? '';

  String labelType() =>
      '$factoryNo - $materialsType - $customsDeclarationType - $supplementType';
}

// class SapLabelBindingPrintInfo {
//   bool isBoxLabel = false; //	标签类型  ZBQLX (05大标 其余小标)
//   String? pieceNo; //	件号  ZPIECE_NO
//   String? labelID; //标签ID BQID
//   String? boxLabelID; //	箱标（大标）  ZDBBQID
//   String?
//       myanmarApprovalDocuments; //缅甸批文成分 Composition of Myanmar approval documents  ZMATCOM
//   String? myanmarApprovalDocumentsEnglish; //缅甸批文成分 英文  ZMATCOM_E
//   String? isTradeFactory; //是否贸易工厂  ZTRADE
//
//   double? long; //	长 ZZCJC
//   double? width; //	宽 ZZCJK,
//   double? height; //	高 ZZCJG
//   double? outWeight; //	外包装重量 ZNTGEW_PZ
//
//   String? factoryNo; //工厂  WERKS
//   String? supplierNumber; //供应商编号  LIFNR
//   String? materialsType; //	物料大类  ZMATNRCAT
//   String? customsDeclarationType; //报关形式  ZCUSDECLARATYPE
//   String? supplementType; //补单  ZISBD
//
//   String? isMixMaterial; //	否混物料 是：'X'  否：''  ZMIX
//   String? labelStatus; //	标签状态  ZBQZT
//   String? referenceSalesOrderNo; //	参考销售单号  POSNR
//   double? grossWeight; //	毛重  BRGEW
//   String? creator; //	创建者 ERNAM
//   String? creationDate; //	创建日期  ERDAT
//   int? printingFrequency; //	打印次数  ZDYCS
//   String? manufactureDate; //	生产日期  ZMADAT
//   int? totalPieceQty; //	总件数 ZTTLCTN
//   int? pieceQty; //	当前件数  ZCURCTN
//   String? remarks; //	备注  ZMSGTT
//   String? deleteFlag; //	删除标记  DELFLG
//   String? materialNumber; //物料编号  MATNR
//   String? materialName; //物料名称 ZMAKTX
//   String? materialEnglishName; //物料英文名称 ZMAKTX_E
//   String? salesOrder; //销售订单号  VBELN
//   String? size; //尺码  SIZE1
//   String? materialCategory; //物料类别  ATTYP
//   double? inBoxQty; //装箱数量 ZXNUM
//   String? unit; //单位 MEINS
//   String? unitEnglish; //英文单位  MEINS_E
//   String? companyNumber; //公司代码  BUKRS
//   double? volume; //装载体积  LADEVOL
//   double? netWeight; //净重  NTGEW
//   String? trackNo; //跟踪号 ZTRACKNO
//   String? customer; //客户  NAME1
//   String? shipToParty; //Ship-To Party SHIPTO
//   String? requirementDate; //需求日期 ZEINDT
//   String? materialGroup; //物料组  MATKL
//   String? salesAndDistributionVoucher; //销售和分销凭证号  ZZVBELN
//   String? part; //部位  ZMDBW
//   String? instructions; //指令 ZVBELN_ORI
//   String? customerSalesOrderNo; //客人销售订单号  ZKVBELN
//   String? purchaseOrder; //采购订单  EBELN
//   String? purchaseOrderLine; //采购订单项目号  EBELP
//   double? capacity; //箱容 ZZXR
//   String? generalMaterialNumber; //一般可配置物料  SATNR
//   String? materialDescription; //物料长描述  ZMAKTX_YB
//   String? materialEnglishDescription; //物料长描述英文  ZMAKTX_YB_E
//   String? factoryType; //工厂型体 ZZXTNO
//   String? factoryDescription; //工厂描述  NAME1_WER
//   String? companyNumberDescription; //公司代码描述  BUTXT
//
//   SapLabelBindingPrintInfo({
//     this.labelID,
//     this.supplierNumber,
//     this.factoryNo,
//     this.customsDeclarationType,
//     this.isTradeFactory,
//     this.isBoxLabel = false,
//     this.pieceNo,
//     this.long,
//     this.width,
//     this.height,
//     this.boxLabelID,
//     this.materialsType,
//     this.myanmarApprovalDocuments,
//     this.myanmarApprovalDocumentsEnglish,
//     this.supplementType,
//     this.outWeight,
//     this.materialNumber,
//     this.materialName,
//     this.materialEnglishName,
//     this.salesOrder,
//     this.size,
//     this.materialCategory,
//     this.inBoxQty,
//     this.unit,
//     this.unitEnglish,
//     this.companyNumber,
//     this.volume,
//     this.netWeight,
//     this.trackNo,
//     this.customer,
//     this.shipToParty,
//     this.requirementDate,
//     this.materialGroup,
//     this.salesAndDistributionVoucher,
//     this.part,
//     this.instructions,
//     this.customerSalesOrderNo,
//     this.purchaseOrder,
//     this.purchaseOrderLine,
//     this.capacity,
//     this.generalMaterialNumber,
//     this.materialDescription,
//     this.materialEnglishDescription,
//     this.factoryType,
//     this.factoryDescription,
//     this.companyNumberDescription,
//     this.referenceSalesOrderNo,
//     this.grossWeight,
//     this.creator,
//     this.creationDate,
//     this.printingFrequency,
//     this.manufactureDate,
//     this.totalPieceQty,
//     this.pieceQty,
//     this.remarks,
//     this.labelStatus,
//     this.deleteFlag,
//     this.isMixMaterial,
//   });
//
//   SapLabelBindingPrintInfo.fromJson(dynamic json) {
//     labelID = json['BQID'];
//     supplierNumber = json['LIFNR'];
//     factoryNo = json['WERKS'];
//     customsDeclarationType = json['ZCUSDECLARATYPE'];
//     isTradeFactory = json['ZTRADE'];
//     isBoxLabel = json['ZBQLX'] == '05';
//     pieceNo = json['ZPIECE_NO'];
//     materialsType = json['ZMATNRCAT'];
//     long = json['ZZCJC'].toString().toDoubleTry();
//     width = json['ZZCJK'].toString().toDoubleTry();
//     height = json['ZZCJG'].toString().toDoubleTry();
//     boxLabelID = json['ZDBBQID'];
//     myanmarApprovalDocuments = json['ZMATCOM'];
//     myanmarApprovalDocumentsEnglish = json['ZMATCOM_E'];
//     supplementType = json['ZISBD'];
//     outWeight = json['ZNTGEW_PZ'];
//     materialNumber = json['MATNR'];
//     materialName = json['ZMAKTX'];
//     materialEnglishName = json['ZMAKTX_E'];
//     salesOrder = json['VBELN'];
//     size = json['SIZE1'];
//     materialCategory = json['ATTYP'];
//     inBoxQty = json['ZXNUM'].toString().toDoubleTry();
//     unit = json['MEINS'];
//     unitEnglish = json['MEINS_E'];
//     companyNumber = json['BUKRS'];
//     volume = json['LADEVOL'].toString().toDoubleTry();
//     netWeight = json['NTGEW'].toString().toDoubleTry();
//     trackNo = json['ZTRACKNO'];
//     customer = json['NAME1'];
//     shipToParty = json['SHIPTO'];
//     requirementDate = json['ZEINDT'];
//     materialGroup = json['MATKL'];
//     salesAndDistributionVoucher = json['ZZVBELN'];
//     part = json['ZMDBW'];
//     instructions = json['ZVBELN_ORI'];
//     customerSalesOrderNo = json['ZKVBELN'];
//     purchaseOrder = json['EBELN'];
//     purchaseOrderLine = json['EBELP'];
//     capacity = json['ZZXR'].toString().toDoubleTry();
//     generalMaterialNumber = json['SATNR'];
//     materialDescription = json['ZMAKTX_YB'];
//     materialEnglishDescription = json['ZMAKTX_YB_E'];
//     factoryType = json['ZZXTNO'];
//     factoryDescription = json['NAME1_WER'];
//     companyNumberDescription = json['BUTXT'];
//     referenceSalesOrderNo = json['POSNR'];
//     grossWeight = json['BRGEW'].toString().toDoubleTry();
//     creator = json['ERNAM'];
//     creationDate = json['ERDAT'];
//     printingFrequency = json['ZDYCS'];
//     manufactureDate = json['ZMADAT'];
//     totalPieceQty = json['ZTTLCTN'];
//     pieceQty = json['ZCURCTN'];
//     remarks = json['ZMSGTT'];
//     labelStatus = json['ZBQZT'];
//     deleteFlag = json['DELFLG'];
//     isMixMaterial = json['ZMIX'];
//   }
// }

class SapPrintLabelInfo {
  RxBool isSelected = false.obs;
  RxDouble splitLong = (0.0).obs;
  RxDouble splitWidth = (0.0).obs;
  RxDouble splitHeight = (0.0).obs;
  bool isNewLabel = false; //是否新标 ISNEW
  String? labelType ; //	标签类型  ZBQLX
  bool isBoxLabel = false; //	标签类型  ZBQLX (05大标 其余小标)
  bool isMixMaterial = false; //	否混物料 是：'X'  否：''  ZMIX
  bool isTradeFactory = false; //	是否贸易工厂 是：'X'  否：''  ZTRADE
  String? labelID; //标签ID BQID
  String? factoryNo; //工厂  WERKS
  String? supplierNumber; //供应商编号  LIFNR
  String? supplierName; //供应商名称  NAME1
  String? pieceID; //	件号  ZPIECE_NO
  double? volume; //装载体积  LADEVOL
  double? grossWeight; //	毛重  BRGEW
  double? netWeight; //净重  NTGEW
  String? manufactureDate; //	生产日期  ZMADAT
  int? totalPieceQty; //	总件数 ZTTLCTN
  String? materialsType; //	物料大类  ZMATNRCAT
  String? remarks; //	备注  ZMSGTT
  String? supplementType; //补单  ZISBD
  double? long; //	长 ZZCJC
  double? width; //	宽 ZZCJK
  double? height; //	高 ZZCJG
  String? trackNo; //跟踪号 ZTRACKNO
  String? customsDeclarationType; //报关形式  ZCUSDECLARATYPE
  String? boxLabelID; //	箱标（大标）  ZDBBQID
  String? packageMethodNo; //包装方式编号  ZNUMBER
  double? outWeight; //	外包装重量 ZNTGEW_PZ
  String? customer; //客户  NAME1
  String? shipToParty; //Ship-To Party SHIPTO
  String? materialDeclarationName; //物料报关品名 ZDECLARATION
  String? typeBody; //工厂型体 ZZXTNOS
  String? instructionNo; //指令  KDAUFS
  String? pieceNo; //件号 件数 ZPACKAGES
  String? factory; //厂区 ZQY
  String? warehouse; //仓库编号及描述 ZLGOBS
  List<SapPrintLabelSubInfo>? subLabel; //GT_OUT_ITEMS

  SapPrintLabelInfo({
    this.isNewLabel = false,
    this.labelType,
    this.isBoxLabel = false,
    this.isMixMaterial = false,
    this.isTradeFactory = false,
    this.labelID,
    this.factoryNo,
    this.supplierNumber,
    this.supplierName,
    this.pieceID,
    this.volume,
    this.grossWeight,
    this.netWeight,
    this.manufactureDate,
    this.totalPieceQty,
    this.materialsType,
    this.remarks,
    this.supplementType,
    this.long,
    this.width,
    this.height,
    this.trackNo,
    this.customsDeclarationType,
    this.boxLabelID,
    this.packageMethodNo,
    this.outWeight,
    this.customer,
    this.shipToParty,
    this.materialDeclarationName,
    this.typeBody,
    this.instructionNo,
    this.pieceNo,
    this.factory,
    this.warehouse,
    this.subLabel,
  });

  SapPrintLabelInfo.fromJson(dynamic json) {
    isNewLabel = json['ISNEW'] == 'X';
    labelType = json['ZBQLX'];
    isBoxLabel =labelType== '05';
    isMixMaterial = json['ZMIX'] == 'X';
    isTradeFactory = json['ZTRADE'] == 'X';
    labelID = json['BQID'];
    factoryNo = json['WERKS'];
    supplierNumber = json['LIFNR'];
    supplierName = json['NAME1'];
    pieceID = json['ZPIECE_NO'];
    volume = json['LADEVOL'].toString().toDoubleTry();
    grossWeight = json['BRGEW'].toString().toDoubleTry();
    netWeight = json['NTGEW'].toString().toDoubleTry();
    manufactureDate = json['ZMADAT'];
    totalPieceQty = json['ZTTLCTN'].toString().toIntTry();
    materialsType = json['ZMATNRCAT'];
    remarks = json['ZMSGTT'];
    supplementType = json['ZISBD'];
    long = json['ZZCJC'].toString().toDoubleTry();
    width = json['ZZCJK'].toString().toDoubleTry();
    height = json['ZZCJG'].toString().toDoubleTry();
    trackNo = json['ZTRACKNO'];
    customsDeclarationType = json['ZCUSDECLARATYPE'];
    boxLabelID = json['ZDBBQID'];
    packageMethodNo = json['ZNUMBER'];
    outWeight = json['ZNTGEW_PZ'].toString().toDoubleTry();
    customer = json['NAME1'];
    shipToParty = json['SHIPTO'];
    materialDeclarationName = json['ZDECLARATION'];
    typeBody = json['ZZXTNOS'];
    instructionNo = json['KDAUFS'];
    pieceNo = json['ZPACKAGES'];
    factory = json['ZQY'];
    warehouse = json['ZLGOBS'];
    subLabel = [
      if (json['GT_OUT_ITEMS'] != null)
        for (var sub in json['GT_OUT_ITEMS']) SapPrintLabelSubInfo.fromJson(sub)
    ];
    splitLong.value = long ?? 0;
    splitWidth.value = width ?? 0;
    splitHeight.value = height ?? 0;
  }

 bool canSubmit() => isTradeFactory
      ? splitLong.value > 0 && splitWidth.value > 0 && splitHeight.value > 0
      : true;

  bool hasSplitQty() => subLabel!.any((v) => v.splitQty.value > 0);

  String formatManufactureDate() =>
      '${manufactureDate?.substring(5, 7)}-${manufactureDate?.substring(8, 10)}-${manufactureDate?.substring(0, 4)}';

  String getLongWidthHeight() =>
      '${long.toShowString()}x${width.toShowString()}x${height.toShowString()}';

  String getLongWidthHeightDescription() =>
      '${long.toShowString()}x${width.toShowString()}x${height.toShowString()}CM(LxWxH)';

  double getInBoxQty() => subLabel!.isEmpty
      ? 0
      : subLabel!.map((v) => v.inBoxQty ?? 0).reduce((a, b) => a.add(b));
}

class SapPrintLabelSubInfo {
  RxDouble canSplitQty = 0.0.obs;
  RxDouble splitQty = 0.0.obs;

  String? labelID; //标签ID BQID
  String? instructionNo; //KDAUF  指令号
  String? size; //尺码  SIZE1
  double? inBoxQty; //装箱数量 ZXNUM
  String? unit; //单位  MEINS
  String? unitEnglish; //英文单位  MEINS_E
  String? customsDeclarationUnit; //报关单位 ZMEINS_CUS
  String? specifications; //规格 GROES
  String? myanmarApprovalDocument; //缅甸批文 ZMYR
  String? generalMaterialNumber; //一般可配置物料  SATNR
  String? materialDescription; //物料长描述  ZMAKTX_YB
  String? materialEnglishDescription; //物料长描述英文  ZMAKTX_YB_E
  String? materialNumber; //物料编号  MATNR
  String? materialName; //物料名称 ZMAKTX
  String? materialEnglishName; //物料英文名称 ZMAKTX_E

  SapPrintLabelSubInfo({
    this.labelID,
    this.instructionNo,
    this.size,
    this.inBoxQty,
    this.unit,
    this.unitEnglish,
    this.customsDeclarationUnit,
    this.specifications,
    this.myanmarApprovalDocument,
    this.generalMaterialNumber,
    this.materialDescription,
    this.materialEnglishDescription,
    this.materialNumber,
    this.materialName,
    this.materialEnglishName,
  });

  SapPrintLabelSubInfo.fromJson(dynamic json) {
    labelID = json['BQID'];
    instructionNo = json['KDAUF'];
    size = json['SIZE1'];
    inBoxQty = json['ZXNUM'].toString().toDoubleTry();
    unit = json['MEINS'];
    unitEnglish = json['MEINS_E'];
    customsDeclarationUnit = json['ZMEINS_CUS'];
    specifications = json['GROES'];
    myanmarApprovalDocument = json['ZMYR'];
    generalMaterialNumber = json['SATNR'];
    materialDescription = json['ZMAKTX_YB'];
    materialEnglishDescription = json['ZMAKTX_YB_E'];
    materialNumber = json['MATNR'];
    materialName = json['ZMAKTX'];
    materialEnglishName = json['ZMAKTX_E'];
    canSplitQty.value = inBoxQty ?? 0;
  }
}

class SapLabelSplitInfo {
  RxDouble long;
  RxDouble width;
  RxDouble height;
  List<SapLabelSplitMaterialInfo> materials = [];

  SapLabelSplitInfo({
    required this.long,
    required this.width,
    required this.height,
    required this.materials,
  });

  hasSpecificationsData() => long > 0 && width > 0 && height > 0;
}

class SapLabelSplitMaterialInfo {
  String materialNumber;
  String materialName;
  double qty;
  String unit;

  SapLabelSplitMaterialInfo({
    required this.materialNumber,
    required this.materialName,
    required this.qty,
    required this.unit,
  });
}
