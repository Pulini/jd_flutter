
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/bluetooth_device.dart';
import 'package:jd_flutter/constant.dart';

import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:permission_handler/permission_handler.dart';

class PrintUtil {
  static final PrintUtil _instance = PrintUtil._internal();
  var bluetoothChannel = const MethodChannel(channelBluetoothFlutterToAndroid);
  var deviceList = <BluetoothDevice>[].obs;
  var isScanning = false.obs;
  var _dialogIsShowing = false;

  factory PrintUtil() => _instance;

  static PrintUtil get instance => _instance;

  PrintUtil._internal() {
    setChannelListener();
  }

  printLabel({
    required List<Uint8List> label,
    Function()? start,
    Function()? success,
    Function()? failed,
  }) async {
    if (!await _getBluetoothPermission()) {
      showSnackBar(title: '蓝牙错误', message: '缺少蓝牙权限');
      return;
    }
    if (!await _bluetoothIsEnable()) {
      showSnackBar(title: '蓝牙错误', message: '当前蓝牙不可用');
      return;
    }
    deviceList.value = await _getScannedDevices();
    debugPrint(
        'label.size=${label.map((v) => v.lengthInBytes).reduce((a, b) => a + b)}');
    if (deviceList.any((v) => v.deviceIsConnected)) {
      _send(label: label, start: start, success: success, failed: failed);
    } else {
      _showBluetoothDialog(
        () =>
            _send(label: label, start: start, success: success, failed: failed),
      );
    }
  }

  printLabelList({
    required List<List<Uint8List>> labelList,
    Function()? start,
    Function(int, int)? progress,
    Function(List<int>, List<int>)? finished,
  }) async {
    if (!await _getBluetoothPermission()) {
      showSnackBar(title: '蓝牙错误', message: '缺少蓝牙权限');
      return;
    }
    if (!await _bluetoothIsEnable()) {
      showSnackBar(title: '蓝牙错误', message: '当前蓝牙不可用');
      return;
    }
    if (!await _bluetoothIsLocationOn()) {
      showSnackBar(title: '蓝牙错误', message: '请打开位置信息');
      return;
    }
    deviceList.value = await _getScannedDevices();
    if (deviceList.any((v) => v.deviceIsConnected)) {
      _sendList(
        labels: labelList,
        start: start,
        progress: progress,
        finished: finished,
      );
    } else {
      _showBluetoothDialog(() => _sendList(
            labels: labelList,
            start: start,
            progress: progress,
            finished: finished,
          ));
    }
  }

  setChannelListener() {
    bluetoothChannel.setMethodCallHandler((call) {
      logger.d(
          'BluetoothChannelMethod：${call.method}  arguments:${call.arguments}');
      switch (call.method) {
        case 'BluetoothState':
          {
            switch (call.arguments) {
              case 'StartScan':
                {
                  isScanning.value = true;
                  break;
                }
              case 'EndScan':
                {
                  isScanning.value = false;
                  break;
                }
              case 'Connected':
                {
                  deviceList
                      .singleWhere(
                        (v) => v.deviceMAC == call.arguments['MAC'],
                      )
                      .deviceIsConnected = true;
                  break;
                }
              case 'Disconnected':
                {
                  deviceList
                      .singleWhere(
                        (v) => v.deviceMAC == call.arguments['MAC'],
                      )
                      .deviceIsConnected = false;
                  break;
                }
              case 'Off':
                {
                  showSnackBar(title: '蓝牙状态变更', message: '蓝牙关闭');
                  break;
                }
              case 'On':
                {
                  showSnackBar(title: '蓝牙状态变更', message: '蓝牙开启');
                  break;
                }
              case 'Open':
                {
                  msgDialog(content: 'bluetooth_open_device'.tr);
                  break;
                }
              case 'Close':
                {
                  deviceList.clear();
                  msgDialog(content: 'bluetooth_close_device'.tr);
                  break;
                }
            }
          }
        case 'BluetoothFind':
          {
            var device = BluetoothDevice(
                deviceName: call.arguments['DeviceName'],
                deviceMAC: call.arguments['DeviceMAC'],
                deviceIsBonded: call.arguments['DeviceBondState'],
                deviceIsConnected: call.arguments['DeviceIsConnected']);
            logger.d('BluetoothFind=${device.toJson()}');
            if (!deviceList.any((v) => v.deviceMAC == device.deviceMAC)) {
              deviceList.add(device);
            }
            break;
          }
        case 'BluetoothDisconnected':
          {
            BluetoothDevice? disconnectDevice;
            for (var dev in deviceList) {
              if (dev.deviceMAC == call.arguments &&
                  dev.deviceIsConnected == true) {
                dev.deviceIsConnected = false;
                disconnectDevice = dev;
              }
            }
            if (disconnectDevice != null) {
              msgDialog(content: '蓝牙设备:${disconnectDevice.deviceName} 连接断开。');
            }
            break;
          }
      }
      return Future.value(call);
    });
  }

  Future<bool> _getBluetoothPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.bluetoothAdvertise
    ].request();
    //granted 通过，denied 被拒绝，permanentlyDenied 拒绝且不在提示
    logger.d('''
  location=${statuses[Permission.location]!.isGranted}
  bluetoothConnect=${statuses[Permission.bluetoothConnect]!.isGranted}
  bluetoothScan=${statuses[Permission.bluetoothScan]!.isGranted}
  bluetooth=${statuses[Permission.bluetooth]!.isGranted}
  bluetoothAdvertise=${statuses[Permission.bluetoothAdvertise]!.isGranted}
  ''');

    if (!statuses[Permission.location]!.isGranted) {
      errorDialog(content: '位置信息权限未开启');
      return false;
    }
    if (GetPlatform.isAndroid &&
        !statuses[Permission.bluetoothConnect]!.isGranted) {
      errorDialog(content: '蓝牙连接权限未开启');
      return false;
    }
    if (GetPlatform.isAndroid &&
        !statuses[Permission.bluetoothScan]!.isGranted) {
      errorDialog(content: '蓝牙扫描权限未开启');
      return false;
    }
    if (!statuses[Permission.bluetooth]!.isGranted) {
      errorDialog(content: '蓝牙权限未开启');
      return false;
    }
    if (GetPlatform.isAndroid &&
        !statuses[Permission.bluetoothAdvertise]!.isGranted) {
      errorDialog(content: '蓝牙广播权限未开启');
      return false;
    }

    if (statuses[Permission.location]!.isGranted &&
        statuses[Permission.bluetooth]!.isGranted) {
      if (GetPlatform.isAndroid) {
        return statuses[Permission.bluetoothConnect]!.isGranted &&
            statuses[Permission.bluetoothScan]!.isGranted &&
            statuses[Permission.bluetoothAdvertise]!.isGranted;
      }
      return true;
    }
    return false;
  }

  Future<List<BluetoothDevice>> _getScannedDevices() async {
    return [
      for (var json in await bluetoothChannel.invokeMethod('GetScannedDevices'))
        BluetoothDevice.fromJson(json)
    ];
  }

  bluetoothIsEnable(Function(bool) enable) {
    bluetoothChannel.invokeMethod('IsEnable').then((value) => enable(value));
  }

  Future<bool> _bluetoothIsEnable() async {
    return await bluetoothChannel.invokeMethod('IsEnable');
  }

  Future<bool> _bluetoothIsLocationOn() async {
    return await bluetoothChannel.invokeMethod('IsLocationOn');
  }

  _scanBluetooth() {
    deviceList.clear();
    bluetoothChannel.invokeMethod('ScanBluetooth').then((value) {
      isScanning.value = value;
    });
  }

  _endScanBluetooth() {
    bluetoothChannel.invokeMethod('EndScanBluetooth').then((value) {
      if (value) isScanning.value = false;
    });
  }

  _connectBluetooth(BluetoothDevice device, Function() connected) {
    loadingShow('bluetooth_connecting'.tr);
    bluetoothChannel.invokeMethod('ConnectBluetooth', device.deviceMAC).then(
      (value) {
        loadingDismiss();
        switch (value) {
          case 0:
            {
              device.deviceIsConnected = true;
              deviceList.refresh();
              connected.call();
              break;
            }
          case 1:
            {
              errorDialog(content: 'bluetooth_connect_error_type1'.tr);
              break;
            }
          case 2:
            {
              errorDialog(content: 'bluetooth_connect_error_type2'.tr);
              break;
            }
          case 3:
            {
              errorDialog(content: 'bluetooth_connect_error_type3'.tr);
              break;
            }
        }
        logger.d('连接蓝牙：${device.deviceName} 结果：$value');
      },
    );
  }

  _closeBluetooth(BluetoothDevice device) {
    loadingShow('bluetooth_closing'.tr);
    bluetoothChannel
        .invokeMethod('CloseBluetooth', device.deviceMAC)
        .then((value) {
      loadingDismiss();
      if (value) {
        device.deviceIsConnected = false;
        deviceList.refresh();
      } else {
        errorDialog(content: 'bluetooth_close_error'.tr);
      }
    });
  }

  // send() async {
  //   bluetoothChannel.invokeMethod(
  //       'SendTSC',
  //       await labelForSurplusMaterial(
  //           qrCode: 'asdghjqweyuizxcc',
  //           machine: 'JT01',
  //           shift: '白班',
  //           startDate: '2024-04-01',
  //           factoryType: 'factoryType',
  //           stubBar: 'stubBarstubBarstubBarstubBar',
  //           stuBarCode: 'stuBarCode12345'));
  // }
  _send({
    required dynamic label,
    required Function()? start,
    required Function()? success,
    required Function()? failed,
  }) async {
    start?.call();
    var code = await bluetoothChannel.invokeMethod('SendTSC', label);
    if (code == 1000) {
      //发送完成
      success?.call();
    } else if (code == 1003) {
      //发送失败
      failed?.call();
    } else if (code == 1007) {
      //通道断开
      Future.delayed(const Duration(milliseconds: 500), () {
        _connectBluetooth(
          deviceList.firstWhere((v) => v.deviceIsConnected),
          () => _send(
              label: label, start: start, success: success, failed: failed),
        );
      });
    }
  }

  _sendList({
    required List<dynamic> labels,
    required Function()? start,
    required Function(int, int)? progress,
    required Function(List<int>, List<int>)? finished,
  }) async {
    start?.call();
    var success = <int>[];
    var fail = <int>[];
    for (var i = 0; i < labels.length; ++i) {
      progress?.call(i + 1, labels.length);
      var code = await bluetoothChannel.invokeMethod('SendTSC', labels[i]);
      if (code == 1000) {
        success.add(i);
      } else if (code == 1003 || code == 1007) {
        fail.add(i);
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    finished?.call(success, fail);
  }

  bool isConnected() => deviceList.any((v) => v.deviceIsConnected);

  disconnected() => isConnected()
      ? _closeBluetooth(deviceList.firstWhere((v) => v.deviceIsConnected))
      : null;

  _item(int index, Function() connected) {
    var device = deviceList[index];
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bluetooth, color: Colors.blueAccent),
        title: device.deviceIsBonded
            ? textSpan(
                hint: device.deviceName,
                text: 'bluetooth_connected'.tr,
                textColor: Colors.green,
              )
            : Text(device.deviceName),
        subtitle: Text(device.deviceMAC),
        trailing: device.deviceIsConnected
            ? TextButton(
                onPressed: () => _closeBluetooth(device),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Colors.red),
                    children: [
                      const WidgetSpan(
                        child: Icon(Icons.square, color: Colors.red),
                        alignment: PlaceholderAlignment.middle,
                      ),
                      TextSpan(text: 'bluetooth_disconnect'.tr),
                    ],
                  ),
                ),
              )
            : TextButton(
                onPressed: () => _connectBluetooth(device, connected),
                child: Text('bluetooth_connect'.tr),
              ),
      ),
    );
  }

  _showBluetoothDialog(Function() connected) {
    if (_dialogIsShowing) return;
    _dialogIsShowing = true;
    Get.dialog(
      Obx(() => pageBody(
            title: '连接蓝牙',
            actions: [
              isScanning.value
                  ? CombinationButton(
                      text: 'bluetooth_stop'.tr,
                      click: () => _endScanBluetooth(),
                      icon: const Icon(
                        Icons.square,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.red,
                    )
                  : CombinationButton(
                      text: 'bluetooth_scan'.tr,
                      click: () => bluetoothIsEnable(
                        (enable) => enable
                            ? _scanBluetooth()
                            : errorDialog(
                                content: 'bluetooth_connect_error_type3'.tr,
                              ),
                      ),
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.green,
                    ),
            ],
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isScanning.value)
                  const Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '正在搜索蓝牙...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: deviceList.length,
                    itemBuilder: (context, index) =>
                        Obx(() => _item(index, connected)),
                  ),
                ),
              ],
            ),
          )),
    ).then((_) => _dialogIsShowing = false);
  }
}
