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
import 'package:jd_flutter/utils/utils.dart';

class PackOrderInfo {
  int? packageId;
  String? date;
  String? packageNo;
  String? billNO;
  String? organizeName;
  String? workCardNo;
  String? productName;
  String? processName;
  String? userName;

  PackOrderInfo({
    this.packageId,
    this.date,
    this.packageNo,
    this.billNO,
    this.organizeName,
    this.workCardNo,
    this.productName,
    this.processName,
    this.userName,
  });

  factory PackOrderInfo.fromJson(Map<String, dynamic> json) {
    return PackOrderInfo(
      packageId: json['PackageID'],
      date: json['Date'],
      packageNo: json['PackageNo'],
      billNO: json['BillNO'],
      organizeName: json['OrganizeName'],
      workCardNo: json['WorkCardNo'],
      productName: json['ProductName'],
      processName: json['ProcessName'],
      userName: json['UserName'],
    );
  }
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
  bool? isPrint;
  bool? isInStock;
  bool? isOutStock;
  List<PartLabelMaterialInfo>? materialList;

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
    this.isPrint,
    this.isInStock,
    this.isOutStock,
    this.materialList,
  });

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
      isPrint: json['IsPrint'],
      isInStock: json['IsInStock'],
      isOutStock: json['IsOutStock'],
      materialList: [
        if (json['MaterialList'] != null)
          for (var item in json['MaterialList'])
            PartLabelMaterialInfo.fromJson(item)
      ],
    );
  }

  List<String> getPartList() =>
      materialList!.map((v) => v.materialName ?? '').toSet().toList();

  List<String> getInstructionList() => materialList!
      .expand((material) => material.instructionList!)
      .map((instruction) => instruction.instruction ?? '')
      .toSet()
      .toList();

  List<String> getSizeList() {
    var list = <String>[];
    var map=<String, int>{};
    for (var v in materialList!) {
      for (var v2 in v.instructionList!) {
        for (var v3 in v2.sizeList!) {
          map[v3.size!]=(map[v3.size]??0)+(v3.auxQty??0);
        }
      }
    }
    loggerF( map);
    return list;
  }
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
