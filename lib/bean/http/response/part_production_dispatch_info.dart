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
import 'package:jd_flutter/utils/extension_util.dart';

class PartProductionDispatchOrderInfo {
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
  String? unitName;
  String? partPictureUrls;
  String? processName;

  PartProductionDispatchOrderInfo(
      {this.workCardID,
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
      this.unitName,
      this.partPictureUrls,
      }
  );
  factory PartProductionDispatchOrderInfo.fromJson(dynamic json) {
    return PartProductionDispatchOrderInfo(
      workCardID: json['WorkCardID'],
      workCardNo: json['WorkCardNo'],
      date: json['FDate'],
      dataType: json['DataType'],
      productID: json['ProductID'],
      productName: json['ProductName'],
      productPicUrl: json['ProductPicUrl'],
      instruction: json['MtoNo'],
      materialNumber: json['MaterialNumber'],
      materialName: json['MaterialName'],
      sizesQuantities: json['SizesQuantities'],
      dispatchQty: json['DispatchQty'].toString().toDoubleTry(),
      unitName: json['UnitName'],
      partPictureUrls: json['PartPictureUrls'],
    );
  }
}