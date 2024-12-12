import '../../../utils/utils.dart';
import '../../../utils/web_api.dart';

class BarCodeInfo {
  int? id;
  String? code;
  String? type;
  String? palletNo;
  String? department;
  bool isUsed=false;
  bool isHave=false;
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
    required this.palletNo,
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


