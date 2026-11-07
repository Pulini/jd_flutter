import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

// ==================== 全局唯一的相机会话 ====================
// 相机是系统独占资源。如果每个扫描界面都各自 new 一个 MobileScanner 并自动启动，
// 后启动的那个会拿到原生 "alreadyStarted" 错误，界面上直接显示成黑底错误页：
// "The MobileScannerController is already running. Stop it before starting again."
// （页面还在栈里又弹扫码弹窗、快速连点弹两个弹窗都会触发）
//
// 这里所有扫描入口共用同一个 controller，用引用计数控制真正的启动/停止，
// 只有最后一个扫描界面会收到识别结果。
final MobileScannerController appScannerController =
    MobileScannerController(autoStart: false);

/// 当前使用相机的扫描界面数量
int _scannerRefCount = 0;

/// 相机启停串行队列，避免多个扫描界面同时初始化时并发 start
Future<void> _scannerQueue = Future.value();

Future<void> _enqueueScannerTask(Future<void> Function() task) {
  _scannerQueue = _scannerQueue.then((_) => task()).catchError((Object e) {
    debugPrint('相机操作失败: $e');
  });
  return _scannerQueue;
}

Future<void> _startCamera() async {
  if (appScannerController.value.isRunning) return;
  try {
    await appScannerController.start();
  } on MobileScannerException catch (e) {
    debugPrint('启动相机失败: ${e.errorCode.message}');
  }
}

Future<void> _stopCamera() async {
  if (!appScannerController.value.isRunning) return;
  try {
    await appScannerController.stop();
  } on Object catch (e) {
    debugPrint('停止相机失败: $e');
  }
}

/// 占用相机（可重入），只有第一个使用者真正启动相机
Future<void> _acquireCamera() => _enqueueScannerTask(() async {
      _scannerRefCount++;
      if (_scannerRefCount == 1) {
        await _startCamera();
        return;
      }
      // 已有扫描界面在扫描时直接复用同一个相机会话。
      // 但 debug 模式下 mobile_scanner 每次挂载 MobileScanner 都会强制 stop 相机
      // （见 SDK 中 kDebugMode 的逻辑），这里重建一次会话，保证新界面也能看到画面。
      if (kDebugMode) {
        await _stopCamera();
        await _startCamera();
      }
    });

/// 释放相机，最后一个使用者退出时才真正停止
Future<void> _releaseCamera() => _enqueueScannerTask(() async {
      if (_scannerRefCount > 0) _scannerRefCount--;
      if (_scannerRefCount > 0) return;
      await _stopCamera();
    });

/// 扫码视图：统一管理相机占用、前后台切换和识别结果分发
class AppScanner extends StatefulWidget {
  const AppScanner({super.key, required this.onDetect});

  /// 识别到条码时回调（已过滤空值）
  final void Function(String code) onDetect;

  @override
  State<AppScanner> createState() => _AppScannerState();
}

class _AppScannerState extends State<AppScanner> with WidgetsBindingObserver {
  /// 扫描界面栈（后进先出），只有栈顶界面处理识别结果
  static final List<_AppScannerState> _scannerStack = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerStack.add(this);
    // 等 MobileScanner 挂载（attach）后再启动相机
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_acquireCamera());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerStack.remove(this);
    unawaited(_releaseCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 只有栈顶界面负责恢复相机
        if (_scannerStack.isNotEmpty && identical(_scannerStack.last, this)) {
          unawaited(_enqueueScannerTask(_startCamera));
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_enqueueScannerTask(_stopCamera));
    }
  }

  void _onDetect(BarcodeCapture capture) {
    // 多个扫描界面同时存活时，只让最上层的界面响应，避免重复处理
    if (_scannerStack.isEmpty || !identical(_scannerStack.last, this)) return;
    var data = capture.barcodes.firstOrNull?.displayValue ?? '';
    if (data.isNotEmpty) widget.onDetect(data);
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: appScannerController,
      onDetect: _onDetect,
    );
  }
}

class Scanner extends StatefulWidget {
  const Scanner({super.key, this.title});

  final String? title;

  String getClassName() => runtimeType.toString();

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  var nativeDeviceOrientationCommunicator =
      NativeDeviceOrientationCommunicator();
  var quarterTurns = 0.obs;
  StreamSubscription<NativeDeviceOrientation>? _orientationSubscription;
  late var scanner = AppScanner(
    onDetect: (data) {
      //flutter 渲染引擎会导致ImpellerValidationBreak偶发异常，导致onDetect被多次触发，
      //需要添加判断当前页是否处于栈内
      if (Get.currentRoute.contains(widget.getClassName())) {
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
      title: widget.title ?? 'widget_scan_qr_code'.tr,
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
  String? title,
  required Function(String code) detect,
}) {
  var detected = false;
  var scanner = AppScanner(
    onDetect: (data) {
      debugPrint('scannerDialog code=$data');
      if (!detected) {
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
            Text(title ?? 'widget_scan_qr_code_hint'.tr),
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

// adb shell am broadcast -a nlscan.action.SCANNER_RESULT --es SCAN_BARCODE1 D70472F507761FD1A4A5BAAC3ED5CE4B
void pdaScanner({required Function(String) scan}) {
  debugPrint('PdaScanner 注册监听');
  const MethodChannel(channelScan).setMethodCallHandler((call) {
    if (!isErrorDialogShowing) {//异常弹窗显示的时候禁止扫码操作
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
    }
    return Future.value(call);
  });
}

void closePdaScanner() {
  debugPrint('PdaScanner 取消监听');
  const MethodChannel(channelScan).setMethodCallHandler(null);
}
