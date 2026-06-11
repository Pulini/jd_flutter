import 'package:collection/collection.dart';
import 'package:get/get.dart';

//{
//   "InterID": 68154,
//   "Date": "2026-02-02",
//   "PackageNo": "CGBZ2025396",
//   "BillNO": "JZ2500107",
//   "OrganizeName": "金帝厂",
//   "WorkCardNo": "P2049414",
//   "ProductName": "PNS26312586-01",
//   "ProcessName": "面部裁断2",
//   "UserName": "系统"
// }
class PackOrderInfo {
  List<OrderPackageInfo> orderPackageList;
  List<PackProfileInfo> packageProfileList;

  PackOrderInfo({
    required this.orderPackageList,
    required this.packageProfileList,
  });

  factory PackOrderInfo.fromJson(dynamic json) {
    return PackOrderInfo(
      orderPackageList: [
        if (json['OrderPackageList'] != null)
          for (var item in json['OrderPackageList'])
            OrderPackageInfo.fromJson(item)
      ],
      packageProfileList: [
        if (json['PackageProfileList'] != null)
          for (var item in json['PackageProfileList'])
            PackProfileInfo.fromJson(item)
      ],
    );
  }
}

class OrderPackageInfo {
  int? packageId;
  String? date;
  String? packageNo;
  String? billNO;
  String? organizeName;
  String? workCardNo;
  String? productName;
  String? processName;
  String? userName;
  double? capacityQty;
  int? packProfileID;

  OrderPackageInfo({
    this.packageId,
    this.date,
    this.packageNo,
    this.billNO,
    this.organizeName,
    this.workCardNo,
    this.productName,
    this.processName,
    this.userName,
    this.capacityQty,
    this.packProfileID,
  });

  factory OrderPackageInfo.fromJson(dynamic json) {
    return OrderPackageInfo(
      packageId: json['PackageID'],
      date: json['Date'],
      packageNo: json['PackageNo'],
      billNO: json['BillNO'],
      organizeName: json['OrganizeName'],
      workCardNo: json['WorkCardNo'],
      productName: json['ProductName'],
      processName: json['ProcessName'],
      userName: json['UserName'],
      capacityQty: json['CapacityQty'],
      packProfileID: json['PackageProfileID'],
    );
  }
}

//"packProfileID": 24,
// "packProfileNumber": "Package26000053",
// "packProfileName": "单部件单码装",
// "BoxCapacity": 50.0
class PackProfileInfo {
  int? packProfileID;
  String? packProfileNumber;
  String? packProfileName;
  double? boxCapacity;

  PackProfileInfo({
    this.packProfileID,
    this.packProfileNumber,
    this.packProfileName,
    this.boxCapacity,
  });

  factory PackProfileInfo.fromJson(dynamic json) {
    return PackProfileInfo(
      packProfileID: json['packProfileID'],
      packProfileNumber: json['packProfileNumber'],
      packProfileName: json['packProfileName'],
      boxCapacity: json['BoxCapacity'],
    );
  }
  Map<String, dynamic> toJson() => {
        'packProfileID': packProfileID,
        'packProfileNumber': packProfileNumber,
        'packProfileName': packProfileName,
        'BoxCapacity': boxCapacity,
      };
}

// "InterID": 68157,
// "ProductName": "PNS26312586-01",
// "LargeCardNo": "99BF5184-5B52-4D70-9C94-F67B4193E413",
// "BillNo": "JZ2500120",
// "BatchNo": "1",
// "FetchDate": "2025-01-31",
// "DeptName": "",
// "SumQty": 840,
// "PackageType": "混码装",
// "PackageUnitName": "箱",
// "IsPrint": false,
// "IsInStock": false,
// "IsOutStock": false,
// "MaterialList": []
class PartLabelInfo {
  RxBool isSelected = false.obs;

  int? interID;
  String? productName;
  String? largeCardNo;
  String? billNo;
  String? batchNo;
  String? fetchDate;
  String? deptName;
  int? sumQty;
  String? packageType;
  String? packageUnitName;
  int? pieceNo;
  int? printCount;
  bool? isInStock;
  bool? isOutStock;
  List<PartLabelMaterialInfo>? materialList;

  List<String> partList = [];
  List<PartLabelInstructionInfo> instructionList = [];
  List<PartLabelSizeInfo> sizeList = [];
  List<String> pictureUrlList = [];
  List<String> pictureThumbnailUrlList = [];

  PartLabelInfo({
    this.interID,
    this.productName,
    this.largeCardNo,
    this.billNo,
    this.batchNo,
    this.fetchDate,
    this.deptName,
    this.sumQty,
    this.packageType,
    this.packageUnitName,
    this.pieceNo,
    this.printCount,
    this.isInStock,
    this.isOutStock,
    this.materialList,
  }) {
    partList = materialList!.map((v) => v.materialName ?? '').toSet().toList();
    instructionList = materialList!
        .expand((material) => material.instructionList!)
        .toSet()
        .toList();
    sizeList = groupBy(
            materialList!
                .expand((m) => m.instructionList!)
                .expand((i) => i.sizeList!),
            (v) => v.size ?? '')
        .values
        .map((v) => PartLabelSizeInfo(
              size: v.first.size ?? '',
              auxQty: v.map((v2) => v2.auxQty ?? 0).reduce((a, b) => a + b),
            ))
        .toList();
    pictureUrlList = materialList!.map((v) => v.pictureUrl ?? '').toList();
    pictureThumbnailUrlList =
        materialList!.map((v) => v.pictureThumbnailUrl ?? '').toList();
  }

  factory PartLabelInfo.fromJson(dynamic json) {
    return PartLabelInfo(
      interID: json['InterID'],
      productName: json['ProductName'],
      largeCardNo: json['LargeCardNo'],
      billNo: json['BillNo'],
      batchNo: json['BatchNo'],
      fetchDate: json['FetchDate'],
      deptName: json['DeptName'],
      sumQty: json['SumQty'],
      packageType: json['PackageType'],
      packageUnitName: json['PackageUnitName'],
      pieceNo: json['PieceNo'],
      printCount: json['PrintCount'],
      isInStock: json['IsInStock'],
      isOutStock: json['IsOutStock'],
      materialList: [
        if (json['MaterialList'] != null)
          for (var item in json['MaterialList'])
            PartLabelMaterialInfo.fromJson(item)
      ],
    );
  }

  String getPartsName() => partList.join(',');

  String getSize() => sizeList.map((v) => '${v.size}/${v.auxQty}').join(' , ');

  int totalQty() => (sumQty! / partList.length).toInt();
}

//"MaterialName": "火腿内外加大版",
//"PictureUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/0bed27df63cf43f2846766ec99b2ed55.png",
//"PictureThumbnailUrl": "https://apptest.goldemperor.com:8084/部件图/2026/1/PNS26312586-01/0bed27df63cf43f2846766ec99b2ed55.png",
//"UnitName": "双",
//"MtoNoList": []
class PartLabelMaterialInfo {
  String? materialName;
  String? pictureUrl;
  String? pictureThumbnailUrl;
  String? unitName;
  List<PartLabelInstructionInfo>? instructionList;

  PartLabelMaterialInfo({
    this.materialName,
    this.pictureUrl,
    this.pictureThumbnailUrl,
    this.unitName,
    this.instructionList,
  });

  factory PartLabelMaterialInfo.fromJson(dynamic json) {
    return PartLabelMaterialInfo(
      materialName: json['MaterialName'],
      pictureUrl: json['PictureUrl'],
      pictureThumbnailUrl: json['PictureThumbnailUrl'],
      unitName: json['UnitName'],
      instructionList: [
        if (json['MtoNoList'] != null)
          for (var item in json['MtoNoList'])
            PartLabelInstructionInfo.fromJson(item)
      ],
    );
  }

  int totalQty() => instructionList!
      .map((v) =>
          v.sizeList!.map((v2) => v2.auxQty ?? 0).reduce((a, b) => a + b))
      .reduce((a, b) => a + b);
}

//"MtoNo": "JZ2500120",
//"SizeList": []
class PartLabelInstructionInfo {
  String? instruction;
  List<PartLabelSizeInfo>? sizeList;

  PartLabelInstructionInfo({this.instruction, this.sizeList});

  factory PartLabelInstructionInfo.fromJson(dynamic json) {
    return PartLabelInstructionInfo(
      instruction: json['MtoNo'],
      sizeList: [
        if (json['SizeList'] != null)
          for (var item in json['SizeList']) PartLabelSizeInfo.fromJson(item)
      ],
    );
  }
}

//"Size": "6",
//"AuxQty": 30
class PartLabelSizeInfo {
  String? size;
  int? auxQty;

  PartLabelSizeInfo({this.size, this.auxQty});

  factory PartLabelSizeInfo.fromJson(dynamic json) {
    return PartLabelSizeInfo(
      size: json['Size'],
      auxQty: json['AuxQty'],
    );
  }
}
