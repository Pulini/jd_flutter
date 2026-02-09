import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

//{
//     "ProductName": "PNS26312586-01",
//     "SeOrderNo": "JZ2500120",
//     "BatchNo": "",
//     "WorkCardQty": 704.0000000000,
//     "WorkCardEntryFID": 556615
// }
class PartDispatchInstructionInfo {
  String? productName;
  String? seOrderNo;
  String? batchNo;
  double? workCardQty;
  int? workCardEntryFID;

  PartDispatchInstructionInfo({
    this.productName,
    this.seOrderNo,
    this.batchNo,
    this.workCardQty,
    this.workCardEntryFID,
  });

  factory PartDispatchInstructionInfo.fromJson(dynamic json) {
    return PartDispatchInstructionInfo(
      productName: json['ProductName'],
      seOrderNo: json['SeOrderNo'],
      batchNo: json['BatchNo'],
      workCardQty: json['WorkCardQty'].toString().toDoubleTry(),
      workCardEntryFID: json['WorkCardEntryFID'].toString().toIntTry(),
    );
  }
}

class PartDispatchOrderBatchGroupInfo {
  String typeBody;
  String batchNo;
  double totalQty;
  List<PartDispatchOrderInstructionGroupInfo> insList;

  PartDispatchOrderBatchGroupInfo({
    required this.typeBody,
    required this.batchNo,
    required this.totalQty,
    required this.insList,
  });

  List<int> getIds() => insList
      .where((v) => v.isSelected.value)
      .expand((v) => v.dataList.map((v2) => v2.workCardEntryFID!))
      .toList();
}

class PartDispatchOrderInstructionGroupInfo {
  RxBool isSelected = false.obs;
  double totalQty;
  List<PartDispatchInstructionInfo> dataList;

  PartDispatchOrderInstructionGroupInfo({
    required this.totalQty,
    required this.dataList,
  });
}

//{
//   "WorkCardNo": "P2049574",
//   "SeOrderNo": "JZ2500120",
//   "ProductName": "PNS26312586-01",
//   "BatchNo": "",
//   "SizeWithQty": "6#:100,6.5#:100,7#:102,7.5#:100,8#:100,8.5#:100,9#:102",
//   "TotalQtyWithUnitName": "704(双)",
//   "ProductUrlList": [
//     "https://apptest.goldemperor.com:8084/金帝集团股份有限公司/型体/2025/11/PNS26312586-01/PNS26312586-01.jpg"
//   ],
//   "PartList": [
//     {
//       "ProductID": "1060060",
//       "MaterialID": "1059709",
//       "ProductName": "PNS26312586-01",
//       "MaterialName": "护眼",
//       "PicItems": [
//         {
//           "PictureUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/73f6770d04b34d77bf8e4e2790cf80b9.png",
//           "PictureThumbnailUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/73f6770d04b34d77bf8e4e2790cf80b9.png"
//         }
//       ],
//       "DispatchQty": 100,
//       "RemainingQty": 500
//     }
//   ]
// }
class PartDispatchOrderDetailInfo {
  String? workCardNo;
  String? seOrderNo;
  String? productName;
  String? batchNo;
  String? sizeWithQty;
  String? totalQtyWithUnitName;
  List<String>? productUrlList;
  List<PartDispatchOrderPartInfo>? partList;

  PartDispatchOrderDetailInfo({
    this.workCardNo,
    this.seOrderNo,
    this.productName,
    this.batchNo,
    this.sizeWithQty,
    this.totalQtyWithUnitName,
    this.productUrlList,
    this.partList,
  });

  factory PartDispatchOrderDetailInfo.fromJson(dynamic json) {
    return PartDispatchOrderDetailInfo(
      workCardNo: json['WorkCardNo'],
      seOrderNo: json['SeOrderNo'],
      productName: json['ProductName'],
      batchNo: json['BatchNo'],
      sizeWithQty: json['SizeWithQty'],
      totalQtyWithUnitName: json['TotalQtyWithUnitName'],
      productUrlList: [
        if (json['ProductUrlList'] != null)
          for (var item in json['ProductUrlList']) item
      ],
      partList: [
        if (json['PartList'] != null)
          for (var item in json['PartList'])
            PartDispatchOrderPartInfo.fromJson(item)
      ],
    );
  }
}

// {
//    "ProductID": "1060060",
//    "MaterialID": "1059709",
//    "ProductName": "PNS26312586-01",
//    "MaterialName": "护眼",
//    "PicItems": [
//      {
//        "PictureUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/73f6770d04b34d77bf8e4e2790cf80b9.png",
//        "PictureThumbnailUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/73f6770d04b34d77bf8e4e2790cf80b9.png"
//      }
//    ],
//    "DispatchQty": 100,
//    "RemainingQty": 500
//  }
class PartDispatchOrderPartInfo {
  RxBool isSelected = false.obs;
  String? productID;
  String? materialID;
  String? productName;
  String? materialName;
  int? packTypeID;
  List<String>? workCardEntryIdList;
  List<PartDispatchOrderPartPicInfo>? picItems;
  double? dispatchQty;
  double? remainingQty;

  PartDispatchOrderPartInfo({
    this.productID,
    this.materialID,
    this.productName,
    this.materialName,
    this.packTypeID,
    this.workCardEntryIdList,
    this.picItems,
    this.dispatchQty,
    this.remainingQty,
  });

  factory PartDispatchOrderPartInfo.fromJson(dynamic json) {
    return PartDispatchOrderPartInfo(
      productID: json['ProductID'],
      materialID: json['MaterialID'],
      productName: json['ProductName'],
      materialName: json['MaterialName'],
      packTypeID: json['PackTypeID'],
      workCardEntryIdList: [
        if (json['WorkCardEntryFIDList'] != null)
          for (var item in json['WorkCardEntryFIDList']) item
      ],
      picItems: [
        if (json['PicItems'] != null)
          for (var item in json['PicItems'])
            PartDispatchOrderPartPicInfo.fromJson(item)
      ],
      dispatchQty: json['DispatchQty'].toString().toDoubleTry(),
      remainingQty: json['RemainingQty'].toString().toDoubleTry(),
    );
  }

  String partPictureUrl() => picItems!.isNotEmpty &&
          picItems!.first.pictureThumbnailUrl?.isNotEmpty == true
      ? picItems!.first.pictureThumbnailUrl!
      : '';
}

//{
//  "PictureUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/73f6770d04b34d77bf8e4e2790cf80b9.png",
//  "PictureThumbnailUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/73f6770d04b34d77bf8e4e2790cf80b9.png"
//}
class PartDispatchOrderPartPicInfo {
  String? pictureUrl;
  String? pictureThumbnailUrl;

  PartDispatchOrderPartPicInfo({
    this.pictureUrl,
    this.pictureThumbnailUrl,
  });

  factory PartDispatchOrderPartPicInfo.fromJson(dynamic json) {
    return PartDispatchOrderPartPicInfo(
      pictureUrl: json['PictureUrl'],
      pictureThumbnailUrl: json['PictureThumbnailUrl'],
    );
  }
}

class PartDispatchOrderCreateInfo {
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
  List<PartDispatchOrderCreateSizeInfo>? sizeList;

  PartDispatchOrderCreateInfo({
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

  factory PartDispatchOrderCreateInfo.fromJson(dynamic json) {
    return PartDispatchOrderCreateInfo(
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
            PartDispatchOrderCreateSizeInfo.fromJson(item)
      ],
    );
  }
}

class PartDispatchOrderCreateSizeInfo {
  int? workCardEntryFID;
  int? workCardID;
  String? workCardNo;
  String? instruction;
  String? materialNumber;
  String? materialName;
  String? size;
  int? capacity;
  int? dispatchedQty;
  int? completedQty;
  int? remainingQty;

  PartDispatchOrderCreateSizeInfo({
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

  factory PartDispatchOrderCreateSizeInfo.fromJson(dynamic json) {
    return PartDispatchOrderCreateSizeInfo(
      workCardEntryFID: json['WorkCardEntryFID'],
      workCardID: json['WorkCardID'],
      workCardNo: json['WorkCardNo'],
      instruction: json['MtoNo'],
      materialNumber: json['MaterialNumber'],
      materialName: json['MaterialName'],
      size: json['Size'],
      capacity: json['Capacity'],
      dispatchedQty: json['DispatchedQty'],
      completedQty: json['CompletedQty'],
      remainingQty: json['RemainingQty'],
    );
  }
}

class CreateLabelInfo {
  var isSelected = false.obs;
  var packageQty = 0.obs;
  var labelCount = 0.obs;
  var sizeList = <PartDispatchOrderCreateSizeInfo>[].obs;
  var partCount = 0;

  CreateLabelInfo(List<PartDispatchOrderCreateSizeInfo> list) {
    sizeList.value = list;
    partCount = groupBy(list, (v) => v.materialName).values.length;
  }

  bool isLegal() => packageQty.value % partCount == 0;

  String size() => sizeList.first.size ?? '';

  int dispatchedQty() =>
      sizeList.map((v) => v.dispatchedQty ?? 0).reduce((a, b) => a + b);

  int kitQty() => groupBy(sizeList, (v) => v.instruction)
      .values
      .map((v) => v.first.dispatchedQty ?? 0)
      .reduce((a, b) => a + b);

  int completedQty() =>
      sizeList.map((v) => v.completedQty ?? 0).reduce((a, b) => a + b);

  int remainingQty() =>
      sizeList.map((v) => v.remainingQty ?? 0).reduce((a, b) => a + b);

  int maxLabelCount() => packageQty.value > 0
      ? (remainingQty() / packageQty.value).ceil()
      : remainingQty().ceil();

  int maxPackageQty() => labelCount.value > 0
      ? (remainingQty() / labelCount.value).ceil()
      : remainingQty();
}
