import 'package:jd_flutter/bean/jpush_notification.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/web_api.dart';

class MessageInfo {
  int? id;
  String? message;
  JPushDoType? doType;
  int? pushDate;
  static const tableName = 'push_message';
  static const dbCreate = '''
      CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      message TEXT NOT NULL,
      doType TEXT NOT NULL,
      pushDate INTEGER
      )
      ''';

  MessageInfo({
    this.id,
    required this.message,
    required this.doType,
  }) {
    pushDate = DateTime.now().millisecondsSinceEpoch;
  }

  MessageInfo.fromJson(dynamic json) {
    id = json['id'];
    message = json['message'];
    doType = JPushDoType.fromString(json['doType'].toString());
    pushDate = DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['message'] = message;
    map['doType'] = doType?.value;
    map['pushDate'] = pushDate;
    return map;
  }
  String getPushTime()=>getCurrentTime(time: DateTime.fromMillisecondsSinceEpoch(pushDate??0));

  save({required Function(MessageInfo) callback}) {
    openDb().then(
      (db) => db
          .insert(
        tableName,
        toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then(
        (value) {
          id = value;
          db.close();
          callback.call(this);
        },
        onError: (e) {
          logger.e('数据库操作异常：$e');
          db.close();
        },
      ),
    );
  }

  static getSave({
    required Function(List<MessageInfo>) callback,
  }) {
    openDb().then((db) {
      db.query(tableName).then((value) {
        db.close();
        callback.call([for (var v in value) MessageInfo.fromJson(v)]);
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

  static clean({
    required Function(int) callback,
  }) {
    openDb().then((db) {
      db.delete(tableName).then((value) {
        db.close();
        callback.call(value);
      }, onError: (e) {
        logger.e('数据库操作异常：$e');
        db.close();
      });
    });
  }
}
