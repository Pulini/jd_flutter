import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/bluetooth_device.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';

import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:permission_handler/permission_handler.dart';

class PrintUtil {
  /// 原生返回的发送状态码
  /// - 1000 发送成功
  /// - 1003 发送失败
  /// - 1006 找不到指定设备
  /// - 1007 蓝牙通道已断开
  /// - 1008 USB 已断开/不可用（等待重新接入后可继续）
  static const int sendSuccess = 1000;
  static const int sendFailed = 1003;
  static const int usbNoDevice = 1006;
  static const int sendBrokenPipe = 1007;
  static const int usbDisconnected = 1008;

  /// 用户在“连接断开”弹窗中点“结束打印”后的返回码：本次打印流程终止
  static const int userAbort = -1;

  /// USB 断开后等待重新接入的最长时间（超时则记为失败）
  static const Duration usbReconnectTimeout = Duration(minutes: 3);

  static final PrintUtil _instance = PrintUtil._internal();
  var bluetoothChannel = const MethodChannel(channelBluetooth);
  var usbChannel = const MethodChannel(channelUsbTsc);
  var deviceList = <BluetoothDevice>[].obs;
  var isScanning = false.obs;
  var _dialogIsShowing = false;

  /// 用户在“连接断开”弹窗中选择了“结束打印”：本次打印流程终止，不再继续下发
  var _abortPrinting = false;

  factory PrintUtil() => _instance;

  static PrintUtil get instance => _instance;

  PrintUtil._internal() {
    setChannelListener();
  }

  Future<void> printLabel({
    required List<Uint8List> label,
    Function()? start,
    Function()? success,
    Function()? failed,
  }) async {
    if (await _getUsbState()) {
      _send(
        mChannel: usbChannel,
        label: label,
        start: start,
        success: success,
        failed: failed,
      );
    } else {
      if (!await _getBluetoothPermission()) {
        showSnackBar(title: 'bluetooth_error'.tr, message: 'bluetooth_missing_permission'.tr);
        return;
      }
      if (!await _bluetoothIsEnable()) {
        showSnackBar(title: 'bluetooth_error'.tr, message: 'bluetooth_unavailable'.tr);
        return;
      }
      deviceList.value = await _getScannedDevices();
      if (deviceList.any((v) => v.deviceIsConnected)) {
        _send(
            mChannel: bluetoothChannel,
            label: label,
            start: start,
            success: success,
            failed: failed);
      } else {
        _showBluetoothDialog(
          () => _send(
              mChannel: bluetoothChannel,
              label: label,
              start: start,
              success: success,
              failed: failed),
        );
      }
    }
  }

  void showBluetoothDialog() {
    _showBluetoothDialog(() {});
  }

  Future<void> printLabelList({
    required List<List<Uint8List>> labelList,
    Function()? start,
    Function(int, int)? progress,
    Function(List<int>, List<int>)? finished,
  }) async {
    if (await _getUsbState()) {
      _sendList(
        mChannel: usbChannel,
        labels: labelList,
        start: start,
        progress: progress,
        finished: finished,
      );
    } else {
      if (!await _getBluetoothPermission()) {
        showSnackBar(title: 'bluetooth_error'.tr, message: 'bluetooth_missing_permission'.tr);
        return;
      }
      if (!await _bluetoothIsEnable()) {
        showSnackBar(title: 'bluetooth_error'.tr, message: 'bluetooth_unavailable'.tr);
        return;
      }
      deviceList.value = await _getScannedDevices();
      if (deviceList.any((v) => v.deviceIsConnected)) {
        _sendList(
          mChannel: bluetoothChannel,
          labels: labelList,
          start: start,
          progress: progress,
          finished: finished,
        );
      } else {
        _showBluetoothDialog(() => _sendList(
              mChannel: bluetoothChannel,
              labels: labelList,
              start: start,
              progress: progress,
              finished: finished,
            ));
      }
    }
  }

  Future<bool> _getUsbState() async {
    return await usbChannel.invokeMethod('isAttached');
  }

  void setChannelListener() {
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
                  showSnackBar(title: 'bluetooth_state_changed'.tr, message: 'bluetooth_state_off'.tr);
                  break;
                }
              case 'On':
                {
                  showSnackBar(title: 'bluetooth_state_changed'.tr, message: 'bluetooth_state_on'.tr);
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
              msgDialog(content: 'bluetooth_device_disconnected'.trArgs([disconnectDevice.deviceName]));
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
  location=${statuses[Permission.location]?.isGranted}
  bluetoothConnect=${statuses[Permission.bluetoothConnect]?.isGranted}
  bluetoothScan=${statuses[Permission.bluetoothScan]?.isGranted}
  bluetooth=${statuses[Permission.bluetooth]?.isGranted}
  bluetoothAdvertise=${statuses[Permission.bluetoothAdvertise]?.isGranted}
  ''');

    if (statuses[Permission.location]?.isGranted == false) {
      errorDialog(content: 'bluetooth_location_permission_denied'.tr);
      return false;
    }
    if (GetPlatform.isAndroid &&
        statuses[Permission.bluetoothConnect]?.isGranted == false) {
      errorDialog(content: 'bluetooth_connect_permission_denied'.tr);
      return false;
    }
    if (GetPlatform.isAndroid &&
        statuses[Permission.bluetoothScan]?.isGranted == false) {
      errorDialog(content: 'bluetooth_scan_permission_denied'.tr);
      return false;
    }
    if (statuses[Permission.bluetooth]?.isGranted == false) {
      errorDialog(content: 'bluetooth_permission_denied'.tr);
      return false;
    }
    if (GetPlatform.isAndroid &&
        statuses[Permission.bluetoothAdvertise]?.isGranted == false) {
      errorDialog(content: 'bluetooth_advertise_permission_denied'.tr);
      return false;
    }
    if (statuses[Permission.location]?.isGranted == true &&
        statuses[Permission.bluetooth]?.isGranted == true) {
      if (GetPlatform.isAndroid) {
        return statuses[Permission.bluetoothConnect]?.isGranted == true &&
            statuses[Permission.bluetoothScan]?.isGranted == true &&
            statuses[Permission.bluetoothAdvertise]?.isGranted == true;
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

  void bluetoothIsEnable(Function(bool) enable) {
    bluetoothChannel.invokeMethod('IsEnable').then((value) => enable(value));
  }

  Future<bool> _bluetoothIsEnable() async {
    return await bluetoothChannel.invokeMethod('IsEnable');
  }

  Future<bool> _bluetoothIsLocationOn() async {
    return await bluetoothChannel.invokeMethod('IsLocationOn');
  }

  void _scanBluetooth() {
    deviceList.clear();
    bluetoothChannel.invokeMethod('ScanBluetooth').then((value) {
      isScanning.value = value;
    });
  }

  void _endScanBluetooth() {
    bluetoothChannel.invokeMethod('EndScanBluetooth').then((value) {
      if (value) isScanning.value = false;
    });
  }

  void _connectBluetooth(BluetoothDevice device, Function() connected) {
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

  void _closeBluetooth(BluetoothDevice device) {
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
  Future<void> _send({
    required MethodChannel mChannel,
    required dynamic label,
    required Function()? start,
    required Function()? success,
    required Function()? failed,
  }) async {
    start?.call();
    var code = await mChannel.invokeMethod('SendTSC', label);
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
              mChannel: mChannel,
              label: label,
              start: start,
              success: success,
              failed: failed),
        );
      });
    }
  }

  Future<void> _sendList({
    required MethodChannel mChannel,
    required List<dynamic> labels,
    required Function()? start,
    required Function(int, int)? progress,
    required Function(List<int>, List<int>)? finished,
  }) async {
    start?.call();
    _abortPrinting = false; // 每次新的打印流程重置“结束打印”标志
    var success = <int>[];
    var fail = <int>[];
    for (var i = 0; i < labels.length; ++i) {
      progress?.call(i + 1, labels.length);
      // 用 _sendOne 发送：USB 断开时会等待重新接入并重发该张（断点继续）
      var code = await _sendOne(mChannel, labels[i]);
      if (code == userAbort) {
        // 用户选择“结束打印”：本次流程终止（已打印的计入成功）
        break;
      }
      if (code == sendSuccess) {
        success.add(i);
      } else if (code == sendFailed || code == sendBrokenPipe) {
        fail.add(i);
      } else if (code == usbDisconnected || code == usbNoDevice) {
        // 等待重连超时（始终未重新接入）才记为失败
        fail.add(i);
      }
      // 不再额外延迟：Kotlin 端 waitPrinterIdle 已串行等打印机就绪，
      // 这里再加延迟只会累积批量打印的总停顿。
    }
    finished?.call(success, fail);
  }

  /// 发送单张标签
  ///
  /// 当返回“USB 已断开”([usbDisconnected] / [usbNoDevice])时，
  /// 会轮询等待打印机重新接入，接入后**重发当前这一张**，
  /// 从而实现“断开重连后自动继续任务”，而不是整批中断。
  ///
  /// 仅在 USB 通道下等待重连；蓝牙沿用原有（1007 断线重连）逻辑。
  Future<int> _sendOne(MethodChannel mChannel, dynamic label) async {
    final deadline = DateTime.now().add(usbReconnectTimeout);
    var notified = false;
    while (true) {
      final result = await mChannel.invokeMethod('SendTSC', label);
      final code = result is int ? result : -1;

      // 非“设备断开”结果：直接返回（成功或普通失败）
      final disconnected = code == usbDisconnected || code == usbNoDevice;
      if (!disconnected) return code;
      // 蓝牙通道不做 USB 重连等待
      if (mChannel != usbChannel) return code;
      // 用户已选择“结束打印”
      if (_abortPrinting) return userAbort;
      // 超过最长等待时间则放弃
      if (DateTime.now().isAfter(deadline)) return code;

      if (!notified) {
        notified = true;
        logger.w('USB 打印机已断开，等待重新接入后自动继续打印...');
        // 提示用户：线路恢复后会自动继续；点“结束打印”则终止本次流程
        _showDisconnectedDialog();
      }
      final reconnected = await _waitUsbReconnect(deadline);
      if (_abortPrinting) return userAbort;
      if (!reconnected) return code;
      // 设备刚接入，给其一点初始化时间再重发当前这张
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  /// 弹出“连接断开”提示：按钮为“结束打印”，点击后本次打印流程终止
  void _showDisconnectedDialog() {
    errorDialog(
      content: 'printer_usb_disconnected_tip'.tr,
      confirmText: 'printer_end_print'.tr,
      back: () => _abortPrinting = true,
    );
  }

  /// 轮询等待 USB 打印机重新接入
  ///
  /// 在 [deadline] 前重新接入返回 true（并自动关闭断开提示弹窗）；
  /// 超时或用户选择“结束打印”返回 false。
  Future<bool> _waitUsbReconnect(DateTime deadline) async {
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (_abortPrinting) return false;
      if (await _getUsbState()) {
        // 线路已恢复：自动关闭断开提示弹窗，随后继续打印
        if (isErrorDialogShowing) Get.back();
        return true;
      }
    }
    return false;
  }

  bool isConnected() => deviceList.any((v) => v.deviceIsConnected);

  dynamic disconnected() => isConnected()
      ? _closeBluetooth(deviceList.firstWhere((v) => v.deviceIsConnected))
      : null;

  Card _item(int index, Function() connected) {
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

  void _showBluetoothDialog(Function() connected) {
    if (_dialogIsShowing) return;
    _dialogIsShowing = true;
    Get.dialog(
      Obx(() => pageBody(
            title: 'bluetooth_connect_dialog_title'.tr,
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
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'bluetooth_scanning'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

void printSetDialog({Function()? print}) {
  RxDouble printSpeed = 5.0.obs;
  RxDouble printDensity = 10.0.obs;
  if (spGet(spSavePrintSpeed) != null) {
    printSpeed.value = spGet(spSavePrintSpeed);
  }
  if (spGet(spSavePrintDensity) != null) {
    printDensity.value = spGet(spSavePrintDensity);
  }
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('print_param_setting'.tr),
        content: SizedBox(
          width: 300,
          height: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Text('print_speed'.tr),
                    Expanded(
                      child: Obx(() => Slider(
                            value: printSpeed.value,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            thumbColor: Colors.blueAccent,
                            activeColor: Colors.green.shade300,
                            onChanged: (v) => printSpeed.value = v,
                          )),
                    ),
                    Obx(() => Text(printSpeed.value.toShowString())),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Text('print_density'.tr),
                    Expanded(
                      child: Obx(() => Slider(
                            value: printDensity.value,
                            min: 1,
                            max: 15,
                            divisions: 14,
                            thumbColor: Colors.blueAccent,
                            activeColor: Colors.green.shade300,
                            onChanged: (v) => printDensity.value = v,
                          )),
                    ),
                    Obx(() => Text(printDensity.value.toShowString())),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              spSave(spSavePrintDensity, printDensity.value);
              spSave(spSavePrintSpeed, printSpeed.value);
              Get.back();
              print?.call();
            },
            child: Text(
              'dialog_default_confirm'.tr,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_back'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}
