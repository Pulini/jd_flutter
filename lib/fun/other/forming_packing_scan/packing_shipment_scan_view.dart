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
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('成型出货装箱扫码'.tr),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('柜号：${state.showCabinetNumber}'),
              Obx(
                () => Text('条码：${state.showCabinetNumber.value}'),
              ),
              Row(
                children: [
                  expandedFrameText(
                    text: '订单号',
                    backgroundColor: Colors.blue.shade50,
                    flex: 3,
                  ),
                  expandedFrameText(
                    text: '已发/应出',
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
                text: '手动添加',
                click: () {

                },
                combination: Combination.intact,
              )
            ],
          )),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (scanCode) => {
          state.checkCode(code:scanCode,success: ()=>{

          })
      },
    );
    super.initState();
  }
}
