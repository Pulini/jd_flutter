import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_logic.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PackingShipmentScanPage extends StatefulWidget {
  const PackingShipmentScanPage({super.key});

  @override
  State<PackingShipmentScanPage> createState() =>
      _PackingShipmentScanPageState();
}

class _PackingShipmentScanPageState extends State<PackingShipmentScanPage> {
  final logic = Get.put(PackingScanLogic());
  final state = Get.find<PackingScanLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'packing_shipment_title'.tr,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('packing_shipment_cabinet_number'.tr +
              state.showCabinetNumber.value),
          Obx(
            () => Text(
                'packing_shipment_code'.tr + state.showCabinetNumber.value),
          ),
          Row(
            children: [
              expandedFrameText(
                text: 'packing_shipment_order_no'.tr,
                backgroundColor: Colors.blue.shade50,
                flex: 3,
              ),
              expandedFrameText(
                text: 'packing_shipment_issued'.tr,
                backgroundColor: Colors.blue.shade50,
                flex: 1,
              )
            ],
          ),
          // Expanded(
          //   child: Obx(
          //         () => ListView.builder(
          //       padding: const EdgeInsets.all(8),
          //       itemCount: state.barCodeList.length,
          //       itemBuilder: (BuildContext context, int index) =>
          //           _item(state.barCodeList[index]),
          //     ),
          //   ),
          // ),
          CombinationButton(
            text: 'packing_shipment_manually_add'.tr,
            click: () {},
            combination: Combination.intact,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (scanCode) => {state.checkCode(code: scanCode, success: () => {})},
    );
    super.initState();
  }
}
