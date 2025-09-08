import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'custom_widget.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({
    super.key,
    this.signature,
    required this.name,
    required this.callback,
  });

  final ByteData? signature;
  final String name;
  final Function(ByteData) callback;

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  var control = HandSignatureControl(
    initialSetup: const SignaturePathSetup(
      threshold: 3,
      smoothRatio: 0.65,
      velocityRange: 2,
    ),
  );
  late RxBool reSignature;
  var nDOC = NativeDeviceOrientationCommunicator();
  var quarterTurns = 0.obs;

  _setOrientation(NativeDeviceOrientation orientation) {
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
    reSignature = (widget.signature == null).obs;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nDOC
          .orientation(useSensor: false)
          .then((orientation) => _setOrientation(orientation));
    });
    nDOC
        .onOrientationChanged(useSensor: false)
        .listen((orientation) => _setOrientation(orientation));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('signature_tips'.tr),
          actions: [
            IconButton(
              onPressed: () {
                if (!reSignature.value) {
                  reSignature.value = true;
                } else {
                  control.clear();
                }
              },
              icon: const Icon(
                Icons.autorenew_outlined,
                color: Colors.red,
                size: 40,
              ),
            ),
            IconButton(
              onPressed: () {
                control.toImage(border: 0).then((image) {
                  if (image == null && widget.signature == null) {
                    showSnackBar(
                      message: 'signature_tips'.tr,
                      isWarning: true,
                    );
                  } else {
                    if (image != null) {
                      Get.back(result: image);
                      widget.callback.call(image);
                    }
                  }
                });
              },
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 40,
              ),
            ),
          ],
        ),
        body: Obx(() => RotatedBox(
              quarterTurns: quarterTurns.value,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                color: Colors.grey.shade200,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 180,
                          color: Colors.black87.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: reSignature.value || widget.signature == null
                          ? HandSignature(
                              control: control,
                              drawer: const ShapeSignatureDrawer(
                                width: 1,
                                maxWidth: 10,
                                color: Colors.blueGrey,
                              ),
                            )
                          : Image.memory(
                              fit: BoxFit.cover,
                              widget.signature!.buffer.asUint8List(),
                            ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class SignatureWithWorkerNumberPage extends StatefulWidget {
  const SignatureWithWorkerNumberPage({
    super.key,
    required this.hint,
    required this.callback,
  });

  final String hint;
  final Function(WorkerInfo, ByteData) callback;

  @override
  State<SignatureWithWorkerNumberPage> createState() =>
      _SignatureWithWorkerNumberPageState();
}

class _SignatureWithWorkerNumberPageState
    extends State<SignatureWithWorkerNumberPage> {
  var control = HandSignatureControl(
    initialSetup: const SignaturePathSetup(
      threshold: 3,
      smoothRatio: 0.65,
      velocityRange: 2,
    ),
  );
  var nDOC = NativeDeviceOrientationCommunicator();
  var quarterTurns = 0.obs;
  WorkerInfo? worker;
  var avatar = ''.obs;
  var name = ''.obs;

  _setOrientation(NativeDeviceOrientation orientation) {
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
      nDOC
          .orientation(useSensor: false)
          .then((orientation) => _setOrientation(orientation));
    });
    nDOC
        .onOrientationChanged(useSensor: false)
        .listen((orientation) => _setOrientation(orientation));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = getScreenSize().width;
    var height = getScreenSize().height;

    var workerCheck = WorkerCheck(
      init: worker?.empCode ?? '',
      hint: widget.hint,
      onChanged: (w) {
        worker = w;
        avatar.value = w?.picUrl ?? '';
        name.value = w?.empName ?? '';
        if (w == null) {
          control.clear();
        }
      },
    );

    var avatarImage = AspectRatio(
      aspectRatio: 1 / 1,
      child: Obx(() => ClipOval(
            child: avatar.isEmpty
                ? Icon(
                    Icons.account_circle,
                    size: 120,
                    color: Colors.grey.shade300,
                  )
                : Image.network(
                    avatar.value,
                    fit: BoxFit.fill,
                  ),
          )),
    );

    var signature = ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: HandSignature(
        control: control,
        drawer: const ShapeSignatureDrawer(
          width: 1,
          maxWidth: 10,
          color: Colors.blueGrey,
        ),
      ),
    );

    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('signature_tips'.tr),
          actions: [
            IconButton(
              onPressed: () => control.clear(),
              icon: const Icon(
                Icons.autorenew_outlined,
                color: Colors.red,
                size: 40,
              ),
            ),
            IconButton(
              onPressed: () {
                control.toImage(border: 0).then((image) {
                  if (image == null) {
                    showSnackBar(
                      message: 'signature_tips'.tr,
                      isWarning: true,
                    );
                  } else {
                    Get.back(result: image);
                    widget.callback.call(worker!, image);
                  }
                });
              },
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 40,
              ),
            ),
          ],
        ),
        body: width < height
            ? Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 90),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 90,
                            right: 0,
                            bottom: 0,
                            child: Obx(() => Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (var s in name.split(''))
                                      Text(
                                        s,
                                        style: TextStyle(
                                          fontSize: 180,
                                          color: Colors.black87
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                  ],
                                )),
                          ),
                          RotatedBox(
                            quarterTurns: quarterTurns.value,
                            child: signature,
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 30,
                      child: SizedBox(
                        width: getScreenSize().width - 220,
                        child: workerCheck,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: avatarImage,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 200,
                      child: ListView(
                        children: [
                          avatarImage,
                          workerCheck,
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              right: 0,
                              bottom: 0,
                              child: Obx(() => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (var s in name.split(''))
                                        Text(
                                          s,
                                          style: TextStyle(
                                            fontSize: 180,
                                            color: Colors.black87
                                                .withValues(alpha: 0.1),
                                          ),
                                        ),
                                    ],
                                  )),
                            ),
                            RotatedBox(
                              quarterTurns: quarterTurns.value,
                              child: signature,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
