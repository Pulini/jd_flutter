import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

bluetooth() async {
  if (await FlutterBluePlus.isSupported == false) {
    showSnackBar(title: '设备异常', message: '当前设备不支持蓝牙');
    return;
  }
  FlutterBluePlus.adapterState.listen((state) async {
    print(state);
    if (state == BluetoothAdapterState.on) {
      ///当前已经连接的蓝牙设备
      List<BluetoothDevice> _systemDevices = [];

      ///扫描到的蓝牙设备
      var scanResults = <ScanResult>[].obs;
      var isScanning = true.obs;

      var scanListen = FlutterBluePlus.scanResults.listen((results) {
        scanResults.value = results;
      }, onError: (error) {
        print('Scan Error:$error');
      });

      var isScanningListen = FlutterBluePlus.isScanning.listen((state) {
        isScanning.value = state;
      });

      if (GetPlatform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }

      var size = MediaQuery.of(Get.overlayContext!).size;
      var bkg = const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      );
      var titleTextStyle = const TextStyle(
        fontSize: 22,
        color: Colors.white,
        decoration: TextDecoration.none,
      );

      showCupertinoModalPopup(
        context: Get.overlayContext!,
        barrierDismissible: false,
        builder: (BuildContext context) => PopScope(
          //拦截返回键
          canPop: false,
          child: SingleChildScrollView(
            primary: true,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              width: size.width,
              padding: const EdgeInsets.all(8.0),
              decoration: bkg,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            isScanning.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CupertinoActivityIndicator(
                                          color: CupertinoColors.white,
                                          radius: 13),
                                      const SizedBox(width: 5),
                                      Text(
                                        '正在搜索蓝牙...',
                                        style: titleTextStyle,
                                      )
                                    ],
                                  )
                                : Text(
                                    '连接蓝牙',
                                    style: titleTextStyle,
                                  ),
                            const SizedBox(height: 30),
                            Container(
                              width: size.width - 60,
                              height: 330,
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              // child: LoginInlet(logic: logic, state: state),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(size.width - 60, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () async {
                                if (isScanning.value) {
                                  FlutterBluePlus.stopScan();
                                  isScanning.value = false;
                                } else {
                                  await FlutterBluePlus.startScan(
                                      // withServices: [Guid("180D")],
                                      // withNames: ["Bluno"],
                                      timeout: const Duration(seconds: 15));
                                  isScanning.value = true;
                                }
                              },
                              child: Text(
                                isScanning.value ? '结束搜索' : '开始搜索',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(height: 10)
                          ],
                        )),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        scanListen.cancel();
                        isScanningListen.cancel();
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      showSnackBar(title: '设备异常', message: '蓝牙不可用');
    }
  });
}
