import 'dart:io';
import 'package:jd_flutter/utils/utils.dart';

/// 01      03      08          00    00    49    41    00      04          00      00    E6  40
/// 模块地址	功能码   返回内容长度	重量= x1 x2 x3 x4        空位    小数位长度    空位     单位   校验码
/// 0x01	  0x03	  0x08	      X1	  X2	  X3	  X4	  0x00	  X5          0x00    X6    **  **
/// SocketClient端
class SocketClientUtil {
  late String ip;
  late int port;
  late Function(double, String) weightListener;
  Function(bool)? connectListener;
  Socket? socket;
  final weightLength = 4;

  SocketClientUtil({
    required this.ip,
    required this.port,
    required this.weightListener,
    this.connectListener,
  });

  connect() {
    Socket.connect(ip, port).then((v) {
      socket = v;
      connectListener?.call(true);
      socket!.listen((u8l) {
        var hexString = u8l.toHexString();
        // print('接收到数据:event=$hexString');
        weightListener.call(_getWeight(hexString), _getUnit(hexString));
      }, onError: (v) {
        connectListener?.call(false);
      }, onDone: () {
        connectListener?.call(false);
      });
    }, onError: (v) {
      connectListener?.call(false);
    });
  }

  close() {
    socket?.close();
  }

  String _getUnit(String hexString) {
    switch (hexString.substring(20, 22)) {
      case '00':
        return 'kg';
      case '01':
        return 'g';
      case '02':
        return 'lb';
      case '03':
        return 'OZ';
    }
    return '';
  }

  String _cover(String qty) {
    if (qty.length < (weightLength + 1)) {
      return '0' * ((weightLength + 1) - qty.length) + qty;
    }
    return qty;
  }

  double _getWeight(String hexString) {
    var qty = _cover(hexString.substring(6, 14).hexToInt().toString());
    var len = hexString.substring(16, 18).hexToInt();
    return '${qty.substring(0, qty.length - len)}.${qty.substring(qty.length - len, qty.length)}'
        .toDoubleTry();
  }
}