import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/bluetooth_device.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/http/web_api.dart';

import 'dialogs.dart';

isConnected(Function(bool) connected) {
  const MethodChannel(channelFlutterSend)
      .invokeMethod('IsConnected')
      .then((value) => connected(value));
}
checkBle(){
  const MethodChannel(channelFlutterSend)
      .invokeMethod('CheckBluetooth');
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

  _openBluetooth() {
    channel.invokeMethod('OpenBluetooth');
  }

  _scanBluetooth() {
    setState(() {
      deviceList.clear();
    });
    channel.invokeMethod('ScanBluetooth');
  }

  _endScanBluetooth() {
    channel.invokeMethod('EndScanBluetooth');
  }

  _connectBluetooth(int index) {
    loadingDialog('bluetooth_connecting'.tr);
    channel
        .invokeMethod('ConnectBluetooth', deviceList[index].deviceMAC)
        .then((value) {
      Get.back();
      switch (value) {
        case 0:
          {
            setState(() {
              deviceList[index].deviceIsConnected = true;
            });
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
            logger.f('创建通道失败');
            errorDialog(content: 'bluetooth_connect_error_type3'.tr);
            break;
          }
      }
      logger.f(value);
    });
  }

  _closeBluetooth(int index) {
    channel
        .invokeMethod('CloseBluetooth', deviceList[index].deviceMAC)
        .then((value) {
      if (value) {
        setState(() {
          deviceList[index].deviceIsConnected = false;
        });
      } else {
        errorDialog(content: 'bluetooth_close_error'.tr);
      }
    });
  }

  _bluetoothListener() {
    channel.setMethodCallHandler((call) {
      logger.f('method：${call.method}  arguments:${call.arguments}');
      switch (call.method) {
        case 'Bluetooth':
          {
            switch (call.arguments) {
              case 1:
                {
                  logger.f('设备不支持蓝牙');
                  errorDialog(content: 'bluetooth_no_device'.tr);
                  break;
                }
              case 2:
                {
                  logger.f('权限被拒绝');
                  errorDialog(content: 'bluetooth_no_permission'.tr);
                  break;
                }
              case 3:
                {
                  logger.f('蓝牙打开');
                  informationDialog(content: 'bluetooth_open_device'.tr);
                  break;
                }
              case 4:
                {
                  logger.f('蓝牙关闭');
                  setState(() {
                    deviceList.clear();
                  });
                  informationDialog(content: 'bluetooth_close_device'.tr);
                  break;
                }
              case 5:
                {
                  logger.f('开始扫描');
                  streamIsScanning.sink.add(true);
                  break;
                }
              case 6:
                {
                  logger.f('结束扫描');
                  streamIsScanning.sink.add(false);
                  break;
                }
              case 7:
                {
                  logger.f('CONNECTED');
                  break;
                }
              case 8:
                {
                  logger.f('DISCONNECTED');
                  break;
                }
            }
            break;
          }
        case 'Connected':
          {
            setState(() {
              deviceList
                  .singleWhere(
                      (element) => element.deviceMAC == call.arguments['MAC'])
                  .deviceIsConnected = true;
            });
            break;
          }
        case 'Disconnected':
          {
            setState(() {
              deviceList
                  .singleWhere(
                      (element) => element.deviceMAC == call.arguments['MAC'])
                  .deviceIsConnected = false;
            });
            break;
          }
        case 'FindBluetooth':
          {
            setState(() {
              var deviceName = call.arguments['DeviceName'];
              var deviceMAC = call.arguments['DeviceMAC'];
              var deviceBondState = call.arguments['DeviceBondState'] == 12;
              var deviceIsConnected = call.arguments['DeviceIsConnected'];
              deviceList.add(BluetoothDevice.fromJson(<String, dynamic>{}
                ..['DeviceName'] = deviceName
                ..['DeviceMAC'] = deviceMAC
                ..['DeviceIsBonded'] = deviceBondState
                ..['DeviceIsConnected'] = deviceIsConnected));
            });
            break;
          }
      }
      return Future.value(null);
    });
  }

  var deviceList = <BluetoothDevice>[];
  var streamIsScanning = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    _bluetoothListener();
    _openBluetooth();
    _getScannedDevices();
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
            children: [
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: deviceList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.bluetooth,
                            color: Colors.blueAccent,
                          ),
                          title: deviceList[index].deviceIsBonded!
                              ? Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: deviceList[index].deviceName,
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
                              : Text(deviceList[index].deviceName!),
                          subtitle: Text(deviceList[index].deviceMAC!),
                          trailing: deviceList[index].deviceIsConnected!
                              ? TextButton(
                                  onPressed: () => _closeBluetooth(index),
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
                                        TextSpan(
                                            text: 'bluetooth_disconnect'.tr),
                                      ],
                                    ),
                                  ))
                              : TextButton(
                                  onPressed: () => _connectBluetooth(index),
                                  child: Text('bluetooth_connect'.tr),
                                ),
                        ),
                      );
                    }),
              ),
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
                  Expanded(
                    flex: 1,
                    child: StreamBuilder<bool>(
                      stream: streamIsScanning.stream,
                      initialData: false,
                      builder: (c, snapshot) {
                        if (snapshot.data!) {
                          return ElevatedButton(
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
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  TextSpan(text: 'bluetooth_stop'.tr),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: () => _isEnable((enable) =>
                                enable ? _scanBluetooth() : _openBluetooth()),
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(color: Colors.green),
                                children: [
                                  const WidgetSpan(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.green,
                                    ),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  TextSpan(text: 'bluetooth_scan'.tr),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
