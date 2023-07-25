import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:permission_handler/permission_handler.dart';

bluetoothDialog(BuildContext context) {
  [
    Permission.location,
    Permission.storage,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ].request().then((status) {
    logger.i(status);
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("蓝牙"),
        content: SizedBox(
          height: 200,
          child: ListView(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              var subscription = flutterBlue.scanResults.listen((results) {
                // do something with scan results
                for (ScanResult r in results) {
                  print('${r.device.localName} found! rssi: ${r.rssi}');
                }
              });
              // flutterBlue.stopScan();
            },
            child: Text("搜索"),
          ),
        ],
      ),
    );
  });
}
