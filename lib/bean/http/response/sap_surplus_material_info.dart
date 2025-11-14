import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';


class MaterialDetailInfo {
  int? itemID;
  String? name;
  String? number;

  MaterialDetailInfo({this.itemID, this.name, this.number});

  MaterialDetailInfo.fromJson(dynamic json) {
    itemID = json['ItemID'];
    name = json['Name'];
    number = json['Number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemID'] = itemID;
    data['Name'] = name;
    data['Number'] = number;
    return data;
  }
}

class SurplusMaterialHistoryInfo {
  String? dispatchNo; //派工单号 DISPATCH_NO
  String? factory = '1500'; //工厂  WERKS
  String? warehouseNumber; //仓库  LGORT
  String? writeOff; //冲销标识 STOKZ
  String? submitDate; //提交日期 ERDAT
  String? surplusMaterialName;
  String? surplusMaterialCode;
  double? surplusMaterialQty;
  double? surplusMaterialExceedQty;

  // String? surplusMaterialName1; //料头名称1  LT1_NAME
  // String? surplusMaterialName2; //料头名称2  LT2_NAME
  // String? surplusMaterialName3; //料头名称3  LT3_NAME
  // String? surplusMaterialCode1; //料头编号1  LT1
  // String? surplusMaterialCode2; //料头编号2  LT2
  // String? surplusMaterialCode3; //料头编号3  LT3
  // double? surplusMaterialQty1; //料头1重量 MENGE1
  // double? surplusMaterialQty2; //料头2重量 MENGE2
  // double? surplusMaterialQty3; //料头3重量 MENGE3
  // double? surplusMaterialExceedQty1; //料头超产1重量 MENGE_CC1
  // double? surplusMaterialExceedQty2; //料头超产2重量 MENGE_CC2
  // double? surplusMaterialExceedQty3; //料头超产3重量 MENGE_CC3
  String? materialDocumentNo; //物料凭证编号 MBLNR
  String? materialVoucherYear; //物料凭证年度  MJAHR
  String? detailID; //明细id ZEILE
  String? message; //消息文本  BAPI_MSG
  String? messageType; //消息类型  BAPI_MTYPE
  String? surplusMaterialType; //料头类型 01：生产、02：研发、03：底厂报废、04、鞋厂报废、05扫地料  LTTYPE
  String? surplusMaterialTypeName; // LTTYPE_STR
  String? typeBody; //型体 ZZGCXT
  String? machine; //机台  ZZPGJT

  SurplusMaterialHistoryInfo({
    this.dispatchNo,
    this.factory,
    this.warehouseNumber,
    this.writeOff,
    this.submitDate,
    this.surplusMaterialName,
    this.surplusMaterialCode,
    this.surplusMaterialQty,
    this.surplusMaterialExceedQty,
    this.materialDocumentNo,
    this.materialVoucherYear,
    this.detailID,
    this.message,
    this.messageType,
    this.surplusMaterialType,
    this.surplusMaterialTypeName,
    this.typeBody,
    this.machine,
  });

  SurplusMaterialHistoryInfo.fromJson(dynamic json) {
    dispatchNo = json['DISPATCH_NO'];
    factory = json['WERKS'];
    warehouseNumber = json['LGORT'];
    writeOff = json['STOKZ'];
    submitDate = json['ERDAT'];

    surplusMaterialName =
        json['LT1_NAME'] ?? json['LT2_NAME'] ?? json['LT3_NAME'];
    surplusMaterialCode = json['LT1'] ?? json['LT2'] ?? json['LT3'];
    surplusMaterialQty = json['MENGE1'] ?? json['MENGE2'] ?? json['MENGE3'];
    surplusMaterialExceedQty =
        json['MENGE_CC1'] ?? json['MENGE_CC2'] ?? json['MENGE_CC3'];
    // surplusMaterialName1 = json['LT1_NAME'];
    // surplusMaterialName2 = json['LT2_NAME'];
    // surplusMaterialName3 = json['LT3_NAME'];
    // surplusMaterialCode1 = json['LT1'];
    // surplusMaterialCode2 = json['LT2'];
    // surplusMaterialCode3 = json['LT3'];
    // surplusMaterialQty1 = json['MENGE1'];
    // surplusMaterialQty2 = json['MENGE2'];
    // surplusMaterialQty3 = json['MENGE3'];
    // surplusMaterialExceedQty1 = json['MENGE_CC1'];
    // surplusMaterialExceedQty2 = json['MENGE_CC2'];
    // surplusMaterialExceedQty3 = json['MENGE_CC3'];
    materialDocumentNo = json['MBLNR'];
    materialVoucherYear = json['MJAHR'];
    detailID = json['ZEILE'];
    message = json['BAPI_MSG'];
    messageType = json['BAPI_MTYPE'];
    surplusMaterialType = json['LTTYPE'];
    surplusMaterialTypeName = json['LTTYPE_STR'];
    typeBody = json['ZZGCXT'];
    machine = json['ZZPGJT'];
  }

  String stateText() {
    switch (messageType) {
      case 'S':
        return '入库成功';
      case 'E':
        return '入库失败';
      default:
        return '未知状态';
    }
  }

  Color stateColor() {
    switch (messageType) {
      case 'S':
        return Colors.green;
      case 'E':
        return Colors.red;
      default:
        return Colors.orangeAccent;
    }
  }
}

class SurplusMaterialLabelInfo {
  int? id;
  String? dispatchNumber;
  String? stubBar;
  String? factory;
  String? date;
  int? nowTime;

  String name = '';
  String number = '';
  double editQty = 0;

  SurplusMaterialLabelInfo({
    this.id,
    this.dispatchNumber,
    this.stubBar,
    this.factory,
    this.date,
    this.nowTime,
  });

  SurplusMaterialLabelInfo.fromData(
      SurplusMaterialLabelInfo data, this.name, this.number) {
    dispatchNumber = data.dispatchNumber;
    stubBar = data.stubBar;
    factory = data.factory;
    date = data.date;
    nowTime = data.nowTime;
  }

  SurplusMaterialLabelInfo.fromJson(dynamic json) {
    id = json['ID'];
    dispatchNumber = json['DispatchNumber'];
    stubBar = json['StubBar'];
    factory = json['Factory'];
    date = json['Date'];
    nowTime = json['NowTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ID'] = id;
    data['DispatchNumber'] = dispatchNumber;
    data['StubBar'] = stubBar;
    data['Factory'] = factory;
    data['Date'] = date;
    data['NowTime'] = nowTime;
    return data;
  }

  static const tableName = 'surplus_material_label';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dispatchNumber TEXT,
      stubBar TEXT,
      factory TEXT,
      date TEXT,
      nowTime INTEGER
      )
      ''';

  save() {
    openDb().then((db) async {
      await db.insert(tableName, toJson());
      db.close();
    });
  }

  Future<bool> isExist() async {
    var db = await openDb();
    var list = await db.query(
      tableName,
      where: 'nowTime = ? AND dispatchNumber = ?',
      whereArgs: [nowTime, dispatchNumber],
    );
    return list.isNotEmpty;
  }

  void delete({required Function() callback}) {
    openDb().then((db) {
      db.delete(tableName, where: 'id = ?', whereArgs: [id]).then((value) {
        db.close();
        callback.call();
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static clear({
    required String type,
    required Function(int) callback,
  }) {
    openDb().then((db) {
      db.delete(tableName, where: 'type = ?', whereArgs: [type]).then((value) {
        db.close();
        callback.call(value);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }
}
