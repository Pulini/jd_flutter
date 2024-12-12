import '../../../utils/utils.dart';
import '../../../utils/web_api.dart';
class MaterialDetailInfo{
 int? itemID;
 String? name;
 String? number;

 MaterialDetailInfo({this.itemID, this.name, this.number});
 MaterialDetailInfo.fromJson(Map<String, dynamic> json) {
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


class SapSurplusMaterialLabelInfo {
  int? id;
  String? dispatchNumber;
  String? stubBar;
  String? factory;
  String? date;
  int? nowTime;

  String name='';
  String number='';
  double editQty=0;

  SapSurplusMaterialLabelInfo({
    this.id,
    this.dispatchNumber,
    this.stubBar,
    this.factory,
    this.date,
    this.nowTime,
  });

  SapSurplusMaterialLabelInfo.fromData(SapSurplusMaterialLabelInfo data,this.name,this.number) {
    dispatchNumber=data.dispatchNumber;
    stubBar=data.stubBar;
    factory=data.factory;
    date=data.date;
    nowTime=data.nowTime;
  }
  SapSurplusMaterialLabelInfo.fromJson(Map<String, dynamic> json) {
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
      nowTime INTEGER,
      )
      ''';

  save({required Function(SapSurplusMaterialLabelInfo) callback}) {
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
    required int nowTime,
    required String dispatchNumber,
    required Function(List<SapSurplusMaterialLabelInfo>) callback,
  }) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'nowTime = ? AND dispatchNumber = ?',
        whereArgs: [nowTime, dispatchNumber],
      ).then((value) {
        db.close();
        callback.call(
            [for (var v in value) SapSurplusMaterialLabelInfo.fromJson(v)]);
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
