import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/bluetooth_device.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../tscUtil.dart';
import 'dialogs.dart';

isConnected(Function(bool) connected) {
  const MethodChannel(channelFlutterSend)
      .invokeMethod('IsConnected')
      .then((value) => connected(value));
}

checkBle() {
  const MethodChannel(channelFlutterSend).invokeMethod('CheckBluetooth');
}

Future<bool> getBluetoothPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.bluetooth,
    Permission.bluetoothAdvertise
  ].request();
  //granted 通过，denied 被拒绝，permanentlyDenied 拒绝且不在提示
  if (statuses[Permission.location]!.isGranted &&
      statuses[Permission.bluetoothConnect]!.isGranted &&
      statuses[Permission.bluetoothScan]!.isGranted &&
      statuses[Permission.bluetooth]!.isGranted &&
      statuses[Permission.bluetoothAdvertise]!.isGranted) {
    return true;
  }
  return false;
}

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({super.key});

  @override
  State<BluetoothDialog> createState() => _BluetoothDialogState();
}

class _BluetoothDialogState extends State<BluetoothDialog> {
  var channel = const MethodChannel(channelFlutterSend);

  _getScannedDevices() {
    channel.invokeMethod('GetScannedDevices');
  }

  _isEnable(Function(bool) enable) {
    channel.invokeMethod('IsEnable').then((value) => enable(value));
  }

  _scanBluetooth() {
    deviceList.clear();
    channel.invokeMethod('ScanBluetooth').then((value) {
      streamIsScanning.value = value;
    });
  }

  _endScanBluetooth() {
    channel.invokeMethod('EndScanBluetooth').then((value) {
      if (value) streamIsScanning.value = false;
    });
  }

  _connectBluetooth(BluetoothDevice device) {
    loadingDialog('bluetooth_connecting'.tr);
    channel.invokeMethod('ConnectBluetooth', device.deviceMAC).then((value) {
      Get.back();
      switch (value) {
        case 0:
          {
            device.deviceIsConnected = true;
            deviceList.refresh();
            _send();
            break;
          }
        case 1:
          {
            logger.f('连接失败');
            errorDialog(content: 'bluetooth_connect_error_type1'.tr);
            break;
          }
        case 2:
          {
            logger.f('未找到设备');
            errorDialog(content: 'bluetooth_connect_error_type2'.tr);
            break;
          }
        case 3:
          {
            logger.f('蓝牙不可用');
            errorDialog(content: 'bluetooth_connect_error_type3'.tr);
            break;
          }
      }
      logger.f(value);
    });
  }

  _send() async {
    channel.invokeMethod(
        'SendTSC',
        await labelForSurplusMaterial(
            qrCode: 'asdghjqweyuizxcc',
            machine: 'JT01',
            shift: '白班',
            startDate: '2024-04-01',
            factoryType: 'factoryType',
            stubBar: 'stubBarstubBarstubBarstubBar',
            stuBarCode: 'stuBarCode12345'));
  }

  _closeBluetooth(BluetoothDevice device) {
    loadingDialog('bluetooth_closing'.tr);
    channel.invokeMethod('CloseBluetooth', device.deviceMAC).then((value) {
      Get.back();
      if (value) {
        device.deviceIsConnected = false;
        deviceList.refresh();
      } else {
        errorDialog(content: 'bluetooth_close_error'.tr);
      }
    });
  }

  _bluetoothListener() {
    channel.setMethodCallHandler((call) {
      logger.f('method：${call.method}  arguments:${call.arguments}');
      switch (call.method) {
        case 'BluetoothState':
          {
            switch (call.arguments) {
              case 'StartScan':
                {
                  streamIsScanning.value = true;
                  break;
                }
              case 'EndScan':
                {
                  streamIsScanning.value = false;
                  break;
                }
              case 'Connected':
                {
                  deviceList
                      .singleWhere((element) =>
                  element.deviceMAC == call.arguments['MAC'])
                      .deviceIsConnected = true;
                  deviceList.refresh();
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
                  informationDialog(content: 'bluetooth_open_device'.tr);
                  break;
                }
              case 'Close':
                {
                  deviceList.clear();
                  informationDialog(content: 'bluetooth_close_device'.tr);
                  break;
                }
            }
          }
        case 'BluetoothFind':
          {
            var deviceName = call.arguments['DeviceName'];
            var deviceMAC = call.arguments['DeviceMAC'];
            var deviceBondState = call.arguments['DeviceBondState'] == 12;
            var deviceIsConnected = call.arguments['DeviceIsConnected'];
            if (!deviceList.any((v) => v.deviceMAC == deviceMAC)) {
              deviceList.add(BluetoothDevice.fromJson(<String, dynamic>{}
                ..['DeviceName'] = deviceName
                ..['DeviceMAC'] = deviceMAC
                ..['DeviceIsBonded'] = deviceBondState
                ..['DeviceIsConnected'] = deviceIsConnected));
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
              informationDialog(
                  content: '蓝牙设备:${disconnectDevice.deviceName} 连接断开。');
              deviceList.refresh();
            }
            break;
          }
      }
      return Future.value(null);
    });
  }

  var deviceList = <BluetoothDevice>[].obs;
  var streamIsScanning = false.obs;

  @override
  void initState() {
    super.initState();
    getBluetoothPermission().then((isGranted) {
      if (isGranted) {
        _bluetoothListener();
        // _openBluetooth();
        _getScannedDevices();
      } else {
        Get.back();
      }
    });
  }

  _item(BluetoothDevice device) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.bluetooth,
          color: Colors.blueAccent,
        ),
        title: device.deviceIsBonded!
            ? Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: device.deviceName,
              ),
              TextSpan(
                text: 'bluetooth_connected'.tr,
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
            ],
          ),
        )
            : Text(device.deviceName!),
        subtitle: Text(device.deviceMAC!),
        trailing: device.deviceIsConnected!
            ? TextButton(
            onPressed: () => _closeBluetooth(device),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(color: Colors.red),
                children: [
                  const WidgetSpan(
                    child: Icon(
                      Icons.square,
                      color: Colors.red,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(text: 'bluetooth_disconnect'.tr),
                ],
              ),
            ))
            : TextButton(
          onPressed: () => _connectBluetooth(device),
          child: Text('bluetooth_connect'.tr),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 400,
        height: 600,
        child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Obx(() => ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: deviceList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _item(deviceList[index]),
                    ))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'bluetooth_back'.tr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(() => Expanded(
                      flex: 1,
                      child: streamIsScanning.value
                          ? ElevatedButton(
                        onPressed: () => _endScanBluetooth(),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(color: Colors.red),
                            children: [
                              const WidgetSpan(
                                child: Icon(
                                  Icons.square,
                                  color: Colors.red,
                                ),
                                alignment:
                                PlaceholderAlignment.middle,
                              ),
                              TextSpan(text: 'bluetooth_stop'.tr),
                            ],
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () => _isEnable((enable) => enable
                            ? _scanBluetooth()
                            : errorDialog(
                            content:
                            'bluetooth_connect_error_type3'
                                .tr)),
                        child: Text.rich(
                          TextSpan(
                            style:
                            const TextStyle(color: Colors.green),
                            children: [
                              const WidgetSpan(
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.green,
                                ),
                                alignment:
                                PlaceholderAlignment.middle,
                              ),
                              TextSpan(text: 'bluetooth_scan'.tr),
                            ],
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
