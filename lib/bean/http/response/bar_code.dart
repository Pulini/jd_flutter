import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

enum BarCodeReportType {
  supplierScanInStock(1,'SupplierScanInStock'), // 供应商扫码入库
  processReportInStock(11,'ProcessReportInStock'), // 工序汇报入库
  productionReportInStock(5,'ProductionReportInStock'), // 生产汇报入库
  productionScanInStock(106,'ProductionScanInStock'), // 生产扫码入库
  productionScanPicking(107,'ProductionScanPicking'), // 生产扫码领料
  formingPosteriorScan(3,'FormingPosteriorScan'), // 成型后段扫码
  warehouseAllocation(6,'WarehouseAllocation'), // 仓库调拨
  jinCanSalesScanningCode(13,'JinCanSalesScanningCode'), // 销售扫码出库
  jinCanMaterialOutStock(14,'JincanMaterialOutStock'), // 金灿领料出库
  injectionMoldingStockIn(1000,'InjectionMoldingStockIn'); // 金臻注塑入库
  final int value;
  final String text;
  const BarCodeReportType(this.value,this.text);
}


class BarCodeInfo {
  int? id;
  String? code;
  String? type;
  String? palletNo;
  String? department;
  bool isUsed = false;
  bool isHave = false;
  static const tableName = 'bar_code';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL UNIQUE,
      type TEXT NOT NULL,
      palletNo TEXT
      )
      ''';

  BarCodeInfo({
    this.id,
    required this.code,
    required this.type,
  });

  BarCodeInfo.fromJson(dynamic json) {
    id = json['id'];
    code = json['code'];
    type = json['type'];
    palletNo = json['palletNo'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['code'] = code;
    map['type'] = type;
    map['palletNo'] = palletNo;
    return map;
  }

  save({required Function(BarCodeInfo) callback}) {
    openDb().then((db) {
      db.insert(tableName, toJson()).then((value) {
        debugPrint('value=$value');
        id = value;
        db.close();
        callback.call(this);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static getSave({
    required String type,
    required Function(List<BarCodeInfo>) callback,
  }) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'type = ?',
        whereArgs: [type],
      ).then((value) {
        db.close();
        callback.call([for (var v in value) BarCodeInfo.fromJson(v)]);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
        callback.call([]);
      });
    });
  }

  delete({required Function() callback}) {
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

  deleteByCode({required Function() callback}) {
    openDb().then((db) {
      db.delete(tableName, where: 'code = ?', whereArgs: [code]).then((value) {
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

class BarCodeProcessInfo {
  int? processFlowID; //制程id
  String? processFlowName; //名称
  String? processNodeName; //节点名称

  BarCodeProcessInfo({
    this.processFlowID,
    this.processFlowName,
    this.processNodeName,
  });
  BarCodeProcessInfo.fromJson(dynamic json) {
    processFlowID = json['ProcessFlowID'];
    processFlowName = json['ProcessFlowName'];
    processNodeName = json['ProcessNodeName'];
  }
  @override
  toString() {
    return '$processFlowName/$processNodeName';
  }
}

