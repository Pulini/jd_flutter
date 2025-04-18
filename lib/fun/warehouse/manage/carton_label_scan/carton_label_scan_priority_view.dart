import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanPriorityPage extends StatefulWidget {
  const CartonLabelScanPriorityPage({super.key});

  @override
  State<CartonLabelScanPriorityPage> createState() => _CartonLabelScanPriorityPageState();
}

class _CartonLabelScanPriorityPageState extends State<CartonLabelScanPriorityPage> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;


  _item(LinkDataSizeList data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.green.shade50],
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
                text: data.scanned.toString(),
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (barCode) {
      logic.scanController.text = barCode;
      if(barCode.length==20){
        logic.queryPriorityCartonLabelInfo(code: barCode);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'carton_label_scan_change_priority'.tr,
      body: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            height: 40,
            child: TextField(
              controller: logic.scanController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 15, right: 10),
                filled: true,
                fillColor: Colors.white54,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                hintText:
                'carton_label_scan_input_or_scan'.tr,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: IconButton(
                  onPressed: () => logic.scanController.clear(),
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.red,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () =>
                      logic.queryCartonLabelInfo(logic.scanController.text),
                  icon: const Icon(
                    Icons.loupe_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
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
              // border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textSpan(
                  hint: 'carton_label_scan_outside_code'.tr,
                  text: state.priorityCartonLabel.value,
                ),
                textSpan(
                  hint: 'carton_label_scan_po_number'.tr,
                  text: state.priorityPo.value,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.priorityCartonInsideLabelList.length,
              itemBuilder: (c, i) => _item(state.priorityCartonInsideLabelList[i]),
            ),
          ),
          CombinationButton(
            text: 'carton_label_scan_submit'.tr,
            click: () => {
                  logic.changePriority()
            },
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    logger.f('触发事件-----');
    super.dispose();
  }
}
