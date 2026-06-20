import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanClearTailDetailPage extends StatefulWidget {
  const CartonLabelScanClearTailDetailPage({super.key});

  @override
  State<CartonLabelScanClearTailDetailPage> createState() =>
      _CartonLabelScanClearTailDetailPageState();
}

class _CartonLabelScanClearTailDetailPageState extends State<CartonLabelScanClearTailDetailPage> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
        body: Obx(()=>Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade100,
                    Colors.blue.shade200,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textSpan(
                    hint: 'carton_label_scan_outside_code'.tr,
                    text: state.cartonLabel.value,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 4,
                      right: 4,
                      bottom: 8,
                    ),
                    child: CustomProgressIndicator(
                      max: state.labelTotal.value.toDouble(),
                      value: state.scannedLabelTotal.value.toDouble(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CombinationButton(
                          text: 'carton_label_scan_rescan_inside_code'.tr,
                          click: () => logic.cleanScanned(),
                          combination: Combination.right,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.outBoxDetail.length,
                      itemBuilder: (c, i) =>
                          _CartonInsideLabelItem(data: state.outBoxDetail[i]),
                    ),
                  ),
                  textSpan(hint: 'carton_label_scan_dispatch_no'.tr, text: state.dispatchNumber.value),
                  CombinationButton(
                    text: 'carton_label_scan_submit'.tr,
                    click: (){

                    },
                  )
                ],
              ),
            )
          ],
        )));
  }
  void _scan() {
    pdaScanner(scan: (barCode) {

    });
  }

  @override
  void initState() {
    _scan();
    super.initState();
  }
}




class _CartonInsideLabelItem extends StatelessWidget {
  final LinkDataSizeLists data;
  const _CartonInsideLabelItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'carton_label_scan_size'.tr,
                text: data.size ?? '',
              ),
              textSpan(
                hint: 'carton_label_scan_inside_label'.tr,
                text: data.priceBarCode ?? '',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'carton_label_scan_label_qty'.tr,
                text: data.labelCount.toString(),
                textColor: Colors.black,
              ),
              textSpan(
                hint: 'carton_label_scan_scanned_qty'.tr,
                text: data.shotQty.toString(),
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
