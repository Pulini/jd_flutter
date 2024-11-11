
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';

import 'custom_widget.dart';

class SignatureView extends StatefulWidget {
  SignatureView({super.key, required this.name, this.signature});

  ByteData? signature;
  final String name;

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  final RxBool reSignature = false.obs;
  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.initState();
  }
@override
  void dispose() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

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
                    if (image != null) widget.signature = image;
                    Get.back(result: image);
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
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          color: Colors.grey.shade200,
          child: Obx(
            () => Stack(
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
          ),
        ),
      ),
    );
  }
}
