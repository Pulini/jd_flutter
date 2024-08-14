import '../utils.dart';
import '../web_api.dart';

class DispatchInfo {
  bool? select;
  bool? resigned;
  String? processName;
  String? processNumber;
  String? number;
  String? name;
  int? empID;
  double? qty;
  double? finishQty;
  double? dispatchQty;

  DispatchInfo({
    this.select = false,
    this.resigned = false,
    this.processName = '',
    this.processNumber = '',
    this.number = '',
    this.name = '',
    this.empID = 0,
    this.qty = 0.0,
    this.finishQty = 0.0,
    this.dispatchQty = 0.0,
  });

  DispatchInfo.fromJson(dynamic json) {
    select = json['select'];
    resigned = json['resigned'];
    processName = json['processName'];
    processNumber = json['processNumber'];
    number = json['number'];
    name = json['name'];
    empID = json['empID'];
    qty = json['qty'];
    finishQty = json['finishQty'];
    dispatchQty = json['dispatchQty'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['select'] = select;
    map['resigned'] = resigned;
    map['processName'] = processName;
    map['processNumber'] = processNumber;
    map['number'] = number;
    map['name'] = name;
    map['empID'] = empID;
    map['qty'] = qty;
    map['finishQty'] = finishQty;
    map['dispatchQty'] = dispatchQty;
    return map;
  }

  String getName() => '<$number>$name';

  String getQty() => qty.toShowString();
}

class ShowDispatch {
  int groupIndex;
  int subIndex;
  String processName;
  String processNumber;
  String name;
  double qty;
  double finishQty;

  ShowDispatch({
    required this.groupIndex,
    required this.subIndex,
    required this.processName,
    required this.processNumber,
    required this.name,
    required this.qty,
    required this.finishQty,
  });
}

class SaveWorkProcedure {
  int? id;
  String? plantBody;
  String? saveTime;
  String? dispatchJson;
  static const tableName = 'work_procedure';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plantBody TEXT NOT NULL,
      saveTime TEXT NOT NULL,
      dispatchJson TEXT NOT NULL
      )
      ''';

  SaveWorkProcedure({
    this.id,
    required this.plantBody,
    required this.saveTime,
    required this.dispatchJson,
  });

  SaveWorkProcedure.fromJson(dynamic json) {
    id = json['id'];
    plantBody = json['plantBody'];
    saveTime = json['saveTime'];
    dispatchJson = json['dispatchJson'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['plantBody'] = plantBody;
    map['saveTime'] = saveTime;
    map['dispatchJson'] = dispatchJson;
    return map;
  }

  save(Function(SaveWorkProcedure) callback) {
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

  static getSave(String plantBody, Function(List<SaveWorkProcedure>) callback) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'plantBody = ?',
        whereArgs: [plantBody],
      ).then((value) {
        db.close();
        var list = <SaveWorkProcedure>[];
        for (var v in value) {
          list.add(SaveWorkProcedure.fromJson(v));
        }
        callback.call(list);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
        callback.call([]);
      });
    });
  }

  delete(Function() callback) {
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
}

class SaveDispatch {
  int? id;
  String? processBillNumber;
  String? cacheJson;
  static const tableName = 'dispatch';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      processBillNumber TEXT NOT NULL UNIQUE,
      cacheJson TEXT NOT NULL
      )
      ''';
  static const dbInsertOrReplace = '''
      INSERT OR REPLACE INTO dispatch (
      id, processBillNumber,
      cacheJson
      ) VALUES (?, ?, ?)
      ''';

  SaveDispatch({
    this.id,
    required this.processBillNumber,
    required this.cacheJson,
  });

  SaveDispatch.fromJson(dynamic json) {
    id = json['id'];
    processBillNumber = json['processBillNumber'];
    cacheJson = json['cacheJson'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['processBillNumber'] = processBillNumber;
    map['cacheJson'] = cacheJson;
    return map;
  }

  save(Function(SaveDispatch) callback) {
    openDb().then((db) {
      db.rawInsert(
        dbInsertOrReplace,
        [id, processBillNumber, cacheJson],
      ).then((value) {
        db.close();
        callback.call(this);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static delete({
    required String processBillNumber,
    Function()? callback,
  }) {
    openDb().then((db) {
      db.delete(
        tableName,
        where: 'processBillNumber = ?',
        whereArgs: [processBillNumber],
      ).then((value) {
        db.close();
        callback?.call();
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }

  static getSave(
    String processBillNumber,
    Function(SaveDispatch) callback,
  ) {
    openDb().then((db) {
      db.query(
        tableName,
        where: 'processBillNumber = ?',
        whereArgs: [processBillNumber],
      ).then((value) {
        db.close();
        if (value.isNotEmpty) {
          callback.call(SaveDispatch.fromJson(value[0]));
        }
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }
}

class CacheJson {
  String? processName;
  String? processNumber;
  List<DispatchInfo>? dispatch;

  CacheJson({
    required this.processName,
    required this.processNumber,
    required this.dispatch,
  });

  CacheJson.fromJson(dynamic json) {
    processName = json['processName'];
    processNumber = json['processNumber'];
    if (json['dispatch'] != null) {
      dispatch = [];
      json['dispatch'].forEach((v) {
        dispatch?.add(DispatchInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['processName'] = processName;
    map['processNumber'] = processNumber;
    map['dispatch'] = dispatch?.map((v) => v.toJson()).toList();
    return map;
  }
}
