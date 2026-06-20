import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanClearTailReportPage extends StatefulWidget {
  const CartonLabelScanClearTailReportPage({super.key});

  @override
  State<CartonLabelScanClearTailReportPage> createState() =>
      _CartonLabelScanClearTailState();
}

class _CartonLabelScanClearTailState extends State<CartonLabelScanClearTailReportPage> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  // Row _item(ScWorkCardSizeInfos data) {
  //   return Row(
  //     children: [
  //       Expanded(
  //           child: _text(
  //               mes: ?? '',
  //               backColor:
  //               data.size == '合计' ? Colors.yellowAccent : Colors.white,
  //               head: false,
  //               paddingNumber: 5)),
  //       Expanded(
  //           child: _text(
  //               mes:,
  //               backColor:
  //               data.size == '合计' ? Colors.yellowAccent : Colors.white,
  //               head: false,
  //               paddingNumber: 5)),
  //       Expanded(
  //           child: _text(
  //               mes:,
  //               backColor:
  //               data.size == '合计' ? Colors.yellowAccent : Colors.white,
  //               head: false,
  //               paddingNumber: 5)),
  //       Expanded(
  //           child: _text(
  //               mes:,
  //               backColor:
  //               data.size == '合计' ? Colors.yellowAccent : Colors.white,
  //               head: false,
  //               paddingNumber: 5)),
  //       Expanded(
  //           child: _text(
  //               mes:,
  //               backColor: data.size == '合计'
  //                   ? Colors.yellowAccent
  //                   : Colors.red.shade200,
  //               head: false,
  //               paddingNumber: 5)),
  //       Expanded(
  //           child: _text(
  //               mes:,
  //               backColor:
  //               data.size == '合计' ? Colors.yellowAccent : Colors.white,
  //               head: false,
  //               paddingNumber: 5)),
  //     ],
  //   );
  // }

  Container _text({
    required String mes,
    required Color backColor,
    required bool head,
    required double paddingNumber,
  }) {
    var textColor = Colors.white;
    if (head) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: paddingNumber, bottom: paddingNumber),
        child: Center(
          child: Text(
            mes,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'carton_label_scan_order_order_clearance'.tr,
        actions: [
          TextButton(
            onPressed: () {

            },
            child: Text(
              'dialog_default_back'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_factory'.tr,
                        text: state.factoryBody.value))),
                Expanded(
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_order'.tr,
                        text: state.salesOrder.value)))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_order'.tr,
                        text: state.salesOrder.value))),
                Expanded(
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_customer_order'.tr,
                        text: state.customerOrderNumber.value)))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_size'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_quality'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_full_box'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_not_full_box'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_completed_quantity'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_arrears'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
              ],
            ),
            // Expanded(
            //   child: Obx(
            //         () =>
            //         ListView.builder(
            //           itemCount: state.showDataList.length,
            //           itemBuilder: (context, index) =>
            //               _item(state.showDataList[index]),
            //         ),
            //   ),
            // ),
          ],
        ));
  }

  @override
  void initState() {
    // _scan();
    super.initState();
  }

  // void _scan() {
  //   pdaScanner(scan: (barCode) {
  //     if (!checkUserPermission('1053603')) { //是否有查询权限
  //       errorDialog(content: 'carton_label_scan_order_tail_box_permission'.tr);
  //     } else {
  //       if (barCode.isNotEmpty) {
  //         if (state.showDataList.isEmpty) {
  //
  //         } else {
  //           if (barCode.startsWith('P')) {
  //             if (!checkUserPermission('1053604')) { //是否有查询权限
  //               errorDialog(
  //                   content: 'carton_label_scan_order_submit_permission'.tr);
  //             } else {
  //
  //             }
  //           } else {
  //
  //           }
  //         }
  //       }else{
  //         if (!checkUserPermission('1053604')) { //是否有查询权限
  //           errorDialog(
  //               content: 'carton_label_scan_order_submit_permission'.tr);
  //         } else {
  //
  //         }
  //       }
  //     }
  //   });
  // }
}
