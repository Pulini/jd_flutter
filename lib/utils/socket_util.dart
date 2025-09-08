import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/utils/extension_util.dart';

//socket连接状态枚举类
enum ConnectState {
  // 未连接
  unConnect(0),

  // 连接中
  connecting(1),

  // 连接成功
  connected(2),

  // 连接失败
  connectError(3),

  // 连接断开
  disconnect(4);

  final int value;

  const ConnectState(this.value);
}

// 01      03      08          00    00    49    41    00      04          00      00    E6  40
// 模块地址	功能码   返回内容长度	重量= x1 x2 x3 x4        空位    小数位长度    空位     单位   校验码
// 0x01	  0x03	  0x08	      X1	  X2	  X3	  X4	  0x00	  X5          0x00    X6    **  **
// SocketClient端
class SocketClientUtil {
  late String ip;
  late int port;
  late Function(double, String) weightListener;
  Function(ConnectState)? connectListener;
  Socket? socket;
  final weightLength = 4;
  ConnectState connectState = ConnectState.unConnect;

  SocketClientUtil({
    required this.ip,
    required this.port,
    required this.weightListener,
    this.connectListener,
  });

  connect() {
    debugPrint('连接设备:$ip $port');
    _stateListener(ConnectState.connecting);
    Socket.connect(ip, port).then((v) {
      socket = v;
      _stateListener(ConnectState.connected);
      socket!.listen((u8l) {
        var hexString = u8l.toHexString();
        // print('接收到数据:event=$hexString');
        weightListener.call(_getWeight(hexString), _getUnit(hexString));
      }, onError: (v) {
        debugPrint('连接异常:$v');
        _stateListener(ConnectState.connectError);
      });
    }, onError: (v) {
      _stateListener(ConnectState.connectError);
    });
  }

  _stateListener(ConnectState state) {
    connectState = state;
    connectListener?.call(state);
  }

  close() {
    if (socket != null && connectState == ConnectState.connected) {
      debugPrint('关闭设备并返回监听:$ip $port');
      socket?.close();
      _stateListener(ConnectState.disconnect);
    }
  }

  clean() {
    if (socket != null && connectState == ConnectState.connected) {
      debugPrint('关闭设备:$ip $port');
      socket?.close();
    }
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
