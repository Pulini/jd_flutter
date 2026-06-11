import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key, this.title = '扫描二维码'});

  final String title;

  String getClassName() => runtimeType.toString();

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  var nativeDeviceOrientationCommunicator =
      NativeDeviceOrientationCommunicator();
  var quarterTurns = 0.obs;
  StreamSubscription<NativeDeviceOrientation>? _orientationSubscription;
  late var scanner = MobileScanner(
    onDetect: (v) {
      var data = v.barcodes.firstOrNull?.displayValue ?? '';
      //flutter 渲染引擎会导致ImpellerValidationBreak偶发异常，导致onDetect被多次触发，
      //需要添加判断当前页是否处于栈内
      if (data.isNotEmpty && Get.currentRoute.contains(widget.getClassName())) {
        Get.back(result: data);
      }
    },
  );

  void _setOrientation(NativeDeviceOrientation orientation) {
    if (orientation == NativeDeviceOrientation.landscapeLeft) {
      quarterTurns.value = 3;
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      quarterTurns.value = 1;
    } else if (orientation == NativeDeviceOrientation.portraitDown) {
      quarterTurns.value = 2;
    } else {
      quarterTurns.value = 0;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nativeDeviceOrientationCommunicator
          .orientation(useSensor: false)
          .then((orientation) => _setOrientation(orientation));
    });
    _orientationSubscription = nativeDeviceOrientationCommunicator
        .onOrientationChanged(useSensor: false)
        .listen((orientation) => _setOrientation(orientation));
    super.initState();
  }

  @override
  void dispose() {
    _orientationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: widget.title,
      body: Center(
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() => RotatedBox(
                  quarterTurns: quarterTurns.value,
                  child: scanner,
                )),
          ),
        ),
      ),
    );
  }
}

void scannerDialog({
  String title = '请扫描二维码',
  required Function(String code) detect,
}) {
  var detected = false;
  var scanner = MobileScanner(
    onDetect: (v) {
      var data = v.barcodes.firstOrNull?.displayValue ?? '';
      debugPrint('scannerDialog code=$data');
      if (data.isNotEmpty && !detected) {
        detected = true;
        detect.call(data);
        Get.back();
      }
    },
  );

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.cancel_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
        content: AspectRatio(
          aspectRatio: 1 / 1,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: scanner,
          ),
        ),
      ),
    ),
  );
}

void pdaScanner({required Function(String) scan}) {
  debugPrint('PdaScanner 注册监听');
  const MethodChannel(channelScanFlutterToAndroid).setMethodCallHandler((call) {
    switch (call.method) {
      case 'PdaScanner':
        {
          scan.call(call.arguments);
        }
        break;
      case 'AkxPdaScanner':
        {
          for (var element in call.arguments) {
            scan.call(element);
          }
        }
        break;
    }
    return Future.value(call);
  });
}

void closePdaScanner() {
  debugPrint('PdaScanner 取消监听');
  const MethodChannel(channelScanFlutterToAndroid).setMethodCallHandler(null);
}
