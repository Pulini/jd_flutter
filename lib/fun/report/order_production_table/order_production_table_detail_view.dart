import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_clear_tail_info.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_logic.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class OrderProductionTableDetailPage extends StatefulWidget {
  const OrderProductionTableDetailPage({super.key});

  @override
  State<OrderProductionTableDetailPage> createState() =>
      _OrderProductionTableDetailPageState();
}

class _OrderProductionTableDetailPageState
    extends State<OrderProductionTableDetailPage> {
  final OrderProductionTableLogic logic = Get.find<OrderProductionTableLogic>();
  final OrderProductionTableState state =
      Get.find<OrderProductionTableLogic>().state;

  var titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade700,
    fontSize: 14,
  );

  var titleLine = VerticalDivider(
    width: 1,
    thickness: 1,
    color: Colors.blue.shade300,
    indent: 5,
    endIndent: 5,
  );

  var subStyle = const TextStyle(
    color: Colors.black87,
    fontSize: 13,
  );

  var subLine = VerticalDivider(
    width: 1,
    thickness: 1,
    color: Colors.blue.shade300,
  );

  Widget _item(ClearTailListInfo data) {
    return Row(
      children: [
        item(data.size ?? '', true),
        item(data.orderQty.toString(), true),
        item(data.fullBoxQty.toString(), true),
        item(data.unFullBoxQty.toString(), true),
        item((data.unFullBoxQty! + data.fullBoxQty!).toString(), true),
        item(data.arrears.toString(), true),
      ],
    );
  }

  Widget item(String text, bool isSub) => ExpandedFrameText(
        text: text,
        borderColor: Colors.blue,
        alignment: Alignment.center,
        isBold: !isSub,
        textColor: isSub ? Colors.black : Colors.blue.shade700,
        backgroundColor:isSub? Colors.white:Colors.grey.shade300,
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Obx(() => InkWell(
                          child: textSpan(
                              hint: 'forming_code_collection_factory'.tr,
                              text: state.factoryBody.value),
                          onTap: () {
                            msgDialog(content: state.factoryBody.value);
                          },
                        ))),
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
                    child: Obx(() => InkWell(
                          child: textSpan(
                              hint: 'forming_code_collection_group'.tr,
                              text: state.groupName.value),
                          onTap: () {
                            msgDialog(content: state.groupName.value);
                          },
                        ))),
                Expanded(
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_customer_order'.tr,
                        text: state.customerOrderNumber.value)))
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                item('carton_label_scan_order_size'.tr, false),
                item('carton_label_scan_order_quality'.tr, false),
                item('carton_label_scan_order_full_box'.tr, false),
                item('carton_label_scan_order_not_full_box'.tr, false),
                item('carton_label_scan_order_completed_quantity'.tr, false),
                item('carton_label_scan_order_arrears'.tr, false),
              ],
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.reportBoxList.length,
                  itemBuilder: (context, index) =>
                      _item(state.reportBoxList[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
