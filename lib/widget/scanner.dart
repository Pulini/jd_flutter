import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '请扫描二维码',
      body: MobileScanner(
        onDetect: (v) {
          Get.back(result: v.barcodes.firstOrNull?.displayValue ?? '');
        },
      ),
    );
  }
}

