import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';

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
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  late RxBool reSignature;

  @override
  void initState() {
    reSignature = (widget.signature == null).obs;
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('请在空白处签名'),
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
                      title: 'snack_bar_default_wrong'.tr,
                      message: '请在空白处签名',
                      isWarning: true,
                    );
                  } else {
                    debugPrint('callback image=${image == null}');
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
        body: Obx(() => Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              color: Colors.grey.shade200,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 180,
                        color: Colors.black87.withOpacity(0.1),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: reSignature.value || widget.signature == null
                        ? HandSignature(
                            control: control,
                            color: Colors.blueGrey,
                            width: 1.0,
                            maxWidth: 10.0,
                            type: SignatureDrawType.shape,
                          )
                        : Image.memory(
                            fit: BoxFit.cover,
                            widget.signature!.buffer.asUint8List(),
                          ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
