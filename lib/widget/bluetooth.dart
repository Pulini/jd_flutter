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
    loadingDialog('正在连接蓝牙...');
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
            errorDialog( content: '连接失败');
            break;
          }
        case 2:
          {
            errorDialog( content: '未找到设备');
            break;
          }
        case 3:
          {
            errorDialog( content: '创建通道失败');
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
        errorDialog( content: '断开失败');
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
                  errorDialog(content: '设备不支持蓝牙');
                  break;
                }
              case 2:
                {
                  logger.f('权限被拒绝');
                  errorDialog( content: '权限被拒绝');
                  break;
                }
              case 3:
                {
                  logger.f('蓝牙打开');
                  informationDialog( content: '蓝牙打开');
                  break;
                }
              case 4:
                {
                  logger.f('蓝牙关闭');
                  setState(() {
                    deviceList.clear();
                  });
                  informationDialog( content: '蓝牙关闭');
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
                                          text: deviceList[index].deviceName),
                                      const TextSpan(
                                        text: ' (已配对)',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(deviceList[index].deviceName!),
                          subtitle: Text(deviceList[index].deviceMAC!),
                          trailing: deviceList[index].deviceIsConnected!
                              ? TextButton(
                                  onPressed: () => _closeBluetooth(index),
                                  child: const Text.rich(
                                    TextSpan(
                                      style: TextStyle(color: Colors.red),
                                      children: [
                                        WidgetSpan(
                                          child: Icon(
                                            Icons.square,
                                            color: Colors.red,
                                          ),
                                          alignment:
                                              PlaceholderAlignment.middle,
                                        ),
                                        TextSpan(text: '断开链接'),
                                      ],
                                    ),
                                  ))
                              : TextButton(
                                  onPressed: () => _connectBluetooth(index),
                                  child: const Text('连接'),
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
                      child: const Text(
                        '返回',
                        style: TextStyle(color: Colors.grey),
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
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(color: Colors.red),
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.square,
                                      color: Colors.red,
                                    ),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  TextSpan(text: '停止'),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: () => _isEnable((enable) =>
                                enable ? _scanBluetooth() : _openBluetooth()),
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(color: Colors.green),
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.green,
                                    ),
                                    alignment: PlaceholderAlignment.middle,
                                  ),
                                  TextSpan(text: '扫描'),
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
