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

class _OrderProductionTableDetailPageState extends State<OrderProductionTableDetailPage> {
  final OrderProductionTableLogic logic = Get.find<OrderProductionTableLogic>();
  final OrderProductionTableState state = Get.find<OrderProductionTableLogic>().state;

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
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.size ?? '',
              style: subStyle,
              textAlign: TextAlign.center,
            ),
          ),
          subLine,
          Expanded(
            child: Text(
              data.orderQty.toString(),
              style: subStyle,
              textAlign: TextAlign.center,
            ),
          ),
          subLine,
          Expanded(
            child: Text(
              data.fullBoxQty.toString(),
              style: subStyle,
              textAlign: TextAlign.center,
            ),
          ),
          subLine,
          Expanded(
            child: Text(
              data.unFullBoxQty.toString(),
              style: subStyle,
              textAlign: TextAlign.center,
            ),
          ),
          subLine,
          Expanded(
            child: Text(
              (data.unFullBoxQty! + data.fullBoxQty!).toString(),
              style: subStyle,
              textAlign: TextAlign.center,
            ),
          ),
          subLine,
          Expanded(
            child: Text(
              data.arrears.toString(),
              style: subStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        body: Column(
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
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_order'.tr,
                        text: state.salesOrder.value))),
                Expanded(
                    child: Obx(() => textSpan(
                        hint: 'forming_code_collection_customer_order'.tr,
                        text: state.customerOrderNumber.value)))
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border(
                  top: BorderSide(color: Colors.blue.shade300, width: 2),
                  left: BorderSide(color: Colors.blue.shade300, width: 2),
                  right: BorderSide(color: Colors.blue.shade300, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_size'.tr,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  titleLine,
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_quality'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  titleLine,
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_full_box'.tr,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  titleLine,
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_not_full_box'.tr,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  titleLine,
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_completed_quantity'.tr,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  titleLine,
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_arrears'.tr,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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
        ));
  }


  @override
  void initState() {
    super.initState();
  }
}
