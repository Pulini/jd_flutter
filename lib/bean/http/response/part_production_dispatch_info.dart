//     {
//       "WorkCardID": 213793,
//       "WorkCardNo": "P2049574",
//       "FDate": "2026-01-03",
//       "DataType": 3,
//       "ProductID": 1060060,
//       "ProductName": "PNS26312586-01",
//       "ProductPicUrl": "https://geapp.goldemperor.com:8084/金帝集团股份有限公司/型体/2025/11/PNS26312586-01/PNS26312586-01.jpg",
//       "MtoNo": "JZ2500119,JZ2500120",
//       "MaterialNumber": "58.00002",
//       "MaterialName": "护眼",
//       "SizesQuantities": "6/200;6.5/202;7/202;7.5/200;8/202;8.5/200;9/102",
//       "DispatchQty": 1308.0,
//       "UnitName": "双",
//       "PartPictureUrls": "https://geapp.goldemperor.com:8084/部件图/2025/12/PNS26312586-01/db83587491b24c8f94cb645f2880bc3a.png",
//       "ProcessName": "护眼下料,面裁报2"
//     }
import 'package:collection/collection.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class PartProductionDispatchOrderInfo {
  RxBool isSelected = false.obs;
  int? workCardID;
  String? workCardNo;
  String? date;
  int? dataType;
  int? productID;
  String? productName;
  String? productPicUrl;
  String? instruction;
  String? materialNumber;
  String? materialName;
  String? sizesQuantities;
  double? dispatchQty;
  double? sumCardNoQty;
  String? unitName;
  String? partPictureUrls;
  String? processName;

  PartProductionDispatchOrderInfo({
    this.workCardID,
    this.workCardNo,
    this.date,
    this.dataType,
    this.productID,
    this.productName,
    this.productPicUrl,
    this.instruction,
    this.materialNumber,
    this.materialName,
    this.sizesQuantities,
    this.dispatchQty,
    this.sumCardNoQty,
    this.unitName,
    this.partPictureUrls,
    this.processName,
  });

  factory PartProductionDispatchOrderInfo.fromJson(dynamic json) {
    return PartProductionDispatchOrderInfo(
      workCardID: json['WorkCardID'],
      workCardNo: json['WorkCardNo'],
      date: json['Date'],
      dataType: json['DataType'],
      productID: json['ProductID'],
      productName: json['ProductName'],
      productPicUrl: json['ProductPicUrl'],
      instruction: json['MtoNo'],
      materialNumber: json['MaterialNumber'],
      materialName: json['MaterialName'],
      sizesQuantities: json['SizesQuantities'],
      dispatchQty: json['DispatchQty'].toString().toDoubleTry(),
      sumCardNoQty: json['SumCardNoQty'].toString().toDoubleTry(),
      unitName: json['UnitName'],
      partPictureUrls: json['PartPictureUrls'],
      processName: json['ProcessName'],
    );
  }
}

// "IsGenerateMaxLabelCount": false,
//  "LabelCount": 0,
//  "WorkCardNo": "P2049574",
//  "ProductID": 1060060,
//  "ProductName": "PNS26312586-01",
//  "MtoNo": "JZ2500119,JZ2500120",
//  "MaterialNumber": "58.00002",
//  "MaterialName": "护眼",
//  "CapacityQty": 0.0,
//  "LabelType": 0,
class PartProductionDispatchOrderDetailInfo {
  bool? isGenerateMaxLabelCount;
  int? labelCount;
  String? workCardNo;
  int? productID;
  String? productName;
  String? instruction;
  String? materialNumber;
  String? materialName;
  double? capacityQty;
  int? labelType;
  List<PartProductionDispatchOrderDetailSizeInfo>? sizeList;

  PartProductionDispatchOrderDetailInfo({
    this.isGenerateMaxLabelCount,
    this.labelCount,
    this.workCardNo,
    this.productID,
    this.productName,
    this.instruction,
    this.materialNumber,
    this.materialName,
    this.capacityQty,
    this.labelType,
    this.sizeList,
  });

  factory PartProductionDispatchOrderDetailInfo.fromJson(dynamic json) {
    return PartProductionDispatchOrderDetailInfo(
        isGenerateMaxLabelCount: json['IsGenerateMaxLabelCount'],
        labelCount: json['LabelCount'],
        workCardNo: json['WorkCardNo'],
        productID: json['ProductID'],
        productName: json['ProductName'],
        instruction: json['MtoNo'],
        materialNumber: json['MaterialNumber'],
        materialName: json['MaterialName'],
        capacityQty: json['CapacityQty'].toString().toDoubleTry(),
        sizeList: [
          if (json['SizeList'] != null)
            for (var item in json['SizeList'])
              PartProductionDispatchOrderDetailSizeInfo.fromJson(item)
        ]);
  }
}

//"WorkCardEntryFID": 556975,
// "WorkCardID": 213793,
// "WorkCardNo": "P2049574",
// "MtoNo": "JZ2500119",
// "MaterialNumber": "58.00002",
// "MaterialName": "护眼",
// "Size": "6",
// "Capacity": 0.0,
// "DispatchedQty": 100.0,
// "CompletedQty": 100.0,
// "RemainingQty": 0.0
class PartProductionDispatchOrderDetailSizeInfo {
  RxBool isSelected = false.obs;
  RxBool isShow = true.obs;
  RxDouble qty = 0.0.obs;

  int? workCardEntryFID;
  int? workCardID;
  String? workCardNo;
  String? instruction;
  String? materialNumber;
  String? materialName;
  String? size;
  double? capacity;
  double? dispatchedQty;
  double? completedQty;
  double? remainingQty;

  PartProductionDispatchOrderDetailSizeInfo({
    this.workCardEntryFID,
    this.workCardID,
    this.workCardNo,
    this.instruction,
    this.materialNumber,
    this.materialName,
    this.size,
    this.capacity,
    this.dispatchedQty,
    this.completedQty,
    this.remainingQty,
  });

  factory PartProductionDispatchOrderDetailSizeInfo.fromJson(dynamic json) {
    return PartProductionDispatchOrderDetailSizeInfo(
      workCardEntryFID: json['WorkCardEntryFID'],
      workCardID: json['WorkCardID'],
      workCardNo: json['WorkCardNo'],
      instruction: json['MtoNo'],
      materialNumber: json['MaterialNumber'],
      materialName: json['MaterialName'],
      size: json['Size'],
      capacity: json['Capacity'].toString().toDoubleTry(),
      dispatchedQty: json['DispatchedQty'].toString().toDoubleTry(),
      completedQty: json['CompletedQty'].toString().toDoubleTry(),
      remainingQty: json['RemainingQty'].toString().toDoubleTry(),
    );
  }
}
// {
//   "ProductName": "PNS26312586-01",
//   "LargeCardNo": "",
//   "MaterialList": [
//     {
//       "MaterialName": "反口里",
//       "MtoNoList": [
//         {
//           "MtoNo": null,
//           "SizeList": [
//             {
//               "Size": "4.5",
//               "AuxQty": 100.0
//             },
//             {
//               "Size": "5",
//               "AuxQty": 200.0
//             }
//           ]
//         }
//       ]
//     },
//     {
//       "MaterialName": "火腿内外加大版",
//       "MtoNoList": [
//         {
//           "MtoNo": null,
//           "SizeList": [
//             {
//               "Size": "6",
//               "AuxQty": 200.0
//             },
//             {
//               "Size": "6.5",
//               "AuxQty": 202.0
//             }
//           ]
//         }
//       ]
//     },
//     {
//       "MaterialName": "舌面",
//       "MtoNoList": [
//         {
//           "MtoNo": null,
//           "SizeList": [
//             {
//               "Size": "4.5",
//               "AuxQty": 100.0
//             },
//             {
//               "Size": "5",
//               "AuxQty": 200.0
//             }
//           ]
//         }
//       ]
//     }
//   ]
// },

class PartProductionDispatchLabelInfo {
  RxBool isSelected = false.obs;
  bool? isInStock;
  String? pictureUrl;
  String? typeBody;
  String? processName;
  String? barCode;
  String? unitName;
  List<PartProductionDispatchLabelPartInfo>? partList;

  PartProductionDispatchLabelInfo({
    this.isInStock,
    this.pictureUrl,
    this.typeBody,
    this.barCode,
    this.unitName,
    this.partList,
  });

  factory PartProductionDispatchLabelInfo.fromJson(dynamic json) {
    return PartProductionDispatchLabelInfo(
        isInStock: json['IsInStock'],
        pictureUrl: json['PictureUrl'],
        typeBody: json['ProductName'],
        barCode: json['LargeCardNo'],
        unitName: json['UnitName'],
        partList: [
          if (json['MaterialList'] != null)
            for (var item in json['MaterialList'])
              PartProductionDispatchLabelPartInfo.fromJson(item)
        ]);
  }

  String getPartList() => [for (var v in partList!) v.partName ?? ''].join('、');

  String getInstructionList() => [
        for (var v in partList!)
          for (var v2 in v.instruction!) v2.instruction ?? ''
      ].join('、');

  String getSizeList() => getTotalSizeList()
      .map((v) => '${v.size}/${v.qty.toShowString()}')
      .join(';');

  double getTotalQty() =>
      partList!.map((v) => v.getTotalQty()).reduce((a, b) => a.add(b));

  List<PartProductionDispatchLabelSizeInfo> getTotalSizeList() {
    var totalSizeList = <PartProductionDispatchLabelSizeInfo>[];
    var sizeList = <PartProductionDispatchLabelSizeInfo>[];
    for (var v1 in partList!) {
      for (var v2 in v1.instruction!) {
        sizeList.addAll(v2.sizeList!);
      }
    }
    groupBy(sizeList, (v) => v.size ?? '').forEach((k, v) {
      totalSizeList.add(
        PartProductionDispatchLabelSizeInfo(
          size: k,
          qty: v.map((v2) => v2.qty ?? 0.0).reduce((a, b) => a.add(b)),
        ),
      );
    });
    return totalSizeList;
  }
}

class PartProductionDispatchLabelPartInfo {
  String? partName;
  List<PartProductionDispatchLabelInstructionInfo>? instruction;

  PartProductionDispatchLabelPartInfo({
    this.partName,
    this.instruction,
  });

  factory PartProductionDispatchLabelPartInfo.fromJson(dynamic json) {
    return PartProductionDispatchLabelPartInfo(
        partName: json['MaterialName'],
        instruction: [
          if (json['MtoNoList'] != null)
            for (var item in json['MtoNoList'])
              PartProductionDispatchLabelInstructionInfo.fromJson(item)
        ]);
  }

  double getTotalQty() =>
      instruction!.map((v) => v.getTotalQty()).reduce((a, b) => a.add(b));
}

class PartProductionDispatchLabelInstructionInfo {
  String? instruction;
  List<PartProductionDispatchLabelSizeInfo>? sizeList;

  PartProductionDispatchLabelInstructionInfo({
    this.instruction,
    this.sizeList,
  });

  factory PartProductionDispatchLabelInstructionInfo.fromJson(dynamic json) {
    return PartProductionDispatchLabelInstructionInfo(
        instruction: json['MtoNo'],
        sizeList: [
          if (json['SizeList'] != null)
            for (var item in json['SizeList'])
              PartProductionDispatchLabelSizeInfo.fromJson(item)
        ]);
  }

  double getTotalQty() =>
      sizeList!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));
}

class PartProductionDispatchLabelSizeInfo {
  String? size;
  double? qty;

  PartProductionDispatchLabelSizeInfo({
    this.size,
    this.qty,
  });

  factory PartProductionDispatchLabelSizeInfo.fromJson(dynamic json) {
    return PartProductionDispatchLabelSizeInfo(
      size: json['Size'],
      qty: json['AuxQty'].toString().toDoubleTry(),
    );
  }
}
