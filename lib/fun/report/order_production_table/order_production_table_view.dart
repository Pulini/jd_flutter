import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_logic.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class OrderProductionTablePage extends StatefulWidget {
  const OrderProductionTablePage({super.key});

  @override
  State<OrderProductionTablePage> createState() =>
      _OrderProductionTablePageState();
}

class _OrderProductionTablePageState extends State<OrderProductionTablePage> {
  final OrderProductionTableLogic logic = Get.put(OrderProductionTableLogic());
  final OrderProductionTableState state =
      Get.find<OrderProductionTableLogic>().state;

  late SpinnerController spinnerController1;

  // 单独拎出来的条目组件
  Widget _item(OrderProductionExecutionInfo item) {
    return GestureDetector(
      onTap: () {
        logic.getDetail(item);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4285F4), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 4,
              offset: Offset(1, 2),
            )
          ],
        ),
        foregroundDecoration: RotatedCornerDecoration.withColor(
          color: item.searchType == 1
              ? Colors.green
              : item.searchType == 2
                  ? Colors.red
                  : item.searchType == 3
                      ? Colors.grey
                      : Colors.blue,
          badgeCornerRadius: const Radius.circular(8),
          badgeSize: const Size(40, 40),
          isEmoji: true,
          textSpan: TextSpan(
            text: item.searchType == 1
                ? 'C'
                : item.searchType == 2
                    ? 'P'
                    : item.searchType == 3
                        ? 'N'
                        : '',
            style: const TextStyle(fontSize: 16, height: 1.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：派工单号 | 派工日期
            Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "派工单号：",
                          style:
                              TextStyle(color: Color(0xFF333333), fontSize: 13),
                        ),
                        TextSpan(
                          text: item.workCardNo ?? "",
                          style: const TextStyle(
                            color: Color(0xFF1967D2),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "派工日期：",
                          style:
                              TextStyle(color: Color(0xFF333333), fontSize: 13),
                        ),
                        TextSpan(
                          text: item.workCardDate ?? "",
                          style: const TextStyle(
                            color: Color(0xFF1967D2),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第二行：指令号 | 交期
            Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "指令号：",
                          style:
                              TextStyle(color: Color(0xFF333333), fontSize: 13),
                        ),
                        TextSpan(
                          text: item.seOrderNo ?? "",
                          style: const TextStyle(
                            color: Color(0xFF1967D2),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "交期：",
                          style:
                              TextStyle(color: Color(0xFF333333), fontSize: 13),
                        ),
                        TextSpan(
                          text: item.fetchDate ?? "",
                          style: const TextStyle(
                            color: Color(0xFF1967D2),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第三行：订单数量 | 扫描数量
            Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "订单数量：",
                          style:
                              TextStyle(color: Color(0xFF333333), fontSize: 13),
                        ),
                        TextSpan(
                          text: item.seOrderQty.toShowString(),
                          style: const TextStyle(
                            color: Color(0xFF1967D2),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "扫描数量：",
                          style:
                              TextStyle(color: Color(0xFF333333), fontSize: 13),
                        ),
                        TextSpan(
                          text: item.scanQty.toString(),
                          style: const TextStyle(
                            color: Color(0xFF1967D2),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),
            // 组别名称
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "组别名称：",
                    style: TextStyle(color: Color(0xFF333333), fontSize: 13),
                  ),
                  TextSpan(
                    text: item.departmentName ?? "",
                    style: const TextStyle(
                      color: Color(0xFF1967D2),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // 工厂型体
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "工厂型体：",
                    style: TextStyle(color: Color(0xFF333333), fontSize: 13),
                  ),
                  TextSpan(
                    text: item.productName ?? "",
                    style: const TextStyle(
                      color: Color(0xFF1967D2),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
        actions: [],
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.tailNumberList.length,
                  itemBuilder: (context, index) =>
                      _item(state.tailNumberList[index]),
                ),
              ),
            ),
          ],
        ),
        queryWidgets: [
          EditText(
            hint: 'carton_label_scan_order_input_command'.tr,
            controller: state.tecCommand,
          ),
          DatePicker(pickerController: state.startDate),
          DatePicker(pickerController: state.endDate),
          Spinner(controller: spinnerController1),
          Obx(
            () => SwitchButton(
              onChanged: (s) {
                state.type.value = s;
              },
              name: state.type.value == true
                  ? 'carton_label_scan_order_dispatch_date'.tr
                  : 'carton_label_scan_order_delivery_time'.tr,
              value: state.type.value,
            ),
          )
        ],
        query: () {
          logic.queryOrderList(
            spinnerController1.select.value,
          );
        });
  }

  @override
  void dispose() {
    Get.delete<OrderProductionTableLogic>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    spinnerController1 = SpinnerController(dataList: state.list1);
  }
}
