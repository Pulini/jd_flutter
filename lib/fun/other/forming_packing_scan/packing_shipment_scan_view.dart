import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_logic.dart';

import '../../../../widget/custom_widget.dart';


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
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('packing_shipment_scan_title'.tr),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('柜号：${state.cabinetNumber}'),
              Obx(
                () => Text('条码：${state.cabinetNumber}'),
              ),
              Expanded(child: Row(
                children: [expandedFrameText(
                  text: '订单号',
                  backgroundColor: Colors.blue.shade50,
                  flex: 1,
                ),
                  expandedFrameText(
                    text: '已发/应出',
                    backgroundColor: Colors.blue.shade50,
                    flex: 1,
                  )
                ],
              )),
              // Obx(()=> )
            ],
          )),
    );
  }
}
