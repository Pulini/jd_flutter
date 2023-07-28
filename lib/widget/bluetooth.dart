import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant.dart';

class BluetoothUtil {
  BluetoothUtil._privateConstructor();

  static final BluetoothUtil instance = BluetoothUtil._privateConstructor();
}

class BluetoothDialog extends StatefulWidget {
  const BluetoothDialog({super.key});

  @override
  State<BluetoothDialog> createState() => _BluetoothDialogState();
}

class _BluetoothDialogState extends State<BluetoothDialog> {
  static const platform = MethodChannel(androidPackageName);

  _openBluetooth() async {
    await platform.invokeMethod('OpenBluetooth');
  }

  _scanBluetooth() async {
    await platform.invokeMethod('ScanBluetooth');
  }

  _endScanBluetooth() async {
    await platform.invokeMethod('EndScanBluetooth');
  }

  _bluetoothListener() {
    const MethodChannel(androidPackageName).setMethodCallHandler((call) {
      logger.f("method：${call.method}  arguments:${call.arguments}");
      switch (call.method) {
        case "Bluetooth":
          {
            switch (call.arguments) {
              case 1:
                {
                  logger.f("设备不支持蓝牙");
                  break;
                }
              case 2:
                {
                  logger.f("权限被拒绝");
                  break;
                }
              case 3:
                {
                  logger.f("蓝牙打开");
                  break;
                }
              case 4:
                {
                  logger.f("蓝牙关闭");
                  break;
                }
              case 5:
                {
                  logger.f("开始扫描");
                  streamIsScanning.sink.add(true);
                  break;
                }
              case 6:
                {
                  logger.f("结束扫描");
                  streamIsScanning.sink.add(false);
                  break;
                }
            }
            break;
          }
        case "FindBluetooth":
          {
            var deviceName = call.arguments["DeviceName"];
            var deviceMAC = call.arguments["DeviceMAC"];
            logger.f("发现蓝牙设备:deviceName=$deviceName deviceMAC=$deviceMAC");
            break;
          }
      }
      return Future.value(null);
    });
  }

  var streamIsScanning = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    _bluetoothListener();
    _openBluetooth();
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
                child: SingleChildScrollView(),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("取消"),
                  ),
                  StreamBuilder<bool>(
                    stream: streamIsScanning.stream,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data!) {
                        return TextButton(
                          onPressed: () => _endScanBluetooth(),
                          child: const Text("停止"),
                        );
                      } else {
                        return TextButton(
                          onPressed: () => _scanBluetooth(),
                          child: const Text("扫描"),
                        );
                      }
                    },
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
